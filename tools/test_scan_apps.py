#!/usr/bin/env python3
"""Regression tests for scan-apps.py using Mach-O fixtures that this test authors and links."""
import json
import os
from pathlib import Path
import plistlib
import shutil
import subprocess
import sys
import tempfile
import unittest

SCRIPT = Path(__file__).with_name("scan-apps.py")
TARGET = ["clang", "-target", "arm64-apple-macos11", "-nostdlib", "-fuse-ld=lld"]


def toolchain_available():
    return all(shutil.which(tool) for tool in ("clang", "ld.lld", "llvm-nm", "llvm-objdump", "llvm-lipo"))


def link(output, source_text, work, args):
    source = work / (output.name + ".c")
    source.write_text(source_text)
    subprocess.run(TARGET + args + [str(source), "-o", str(output)], check=True, capture_output=True, cwd=work)


def dylib(output, source_text, work, install, reexport=(), sysroot=None):
    args = ["-dynamiclib", "-Wl,-install_name," + install]
    if sysroot:
        args.append("-Wl,-syslibroot," + str(sysroot))
    for library in reexport:
        args.append("-Wl,-reexport_library," + str(library))
    link(output, source_text, work, args)


def app(root, name, source_text, work, libraries, corrupt=False):
    contents = root / "Applications" / (name + ".app") / "Contents"
    (contents / "MacOS").mkdir(parents=True)
    (contents / "Info.plist").write_bytes(plistlib.dumps({"CFBundleExecutable": name}))
    executable = contents / "MacOS" / name
    if corrupt:
        executable.write_bytes(b"\xcf\xfa\xed\xfe" + b"\x00" * 8)
        return
    args = ["-Wl,-e,_main", "-Wl,-U,dyld_stub_binder", "-L" + str(work)] + ["-l" + lib for lib in libraries]
    link(executable, source_text, work, args)


@unittest.skipUnless(toolchain_available(), "clang, lld and the llvm Mach-O tools are required")
class ScanAppsTest(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.root = Path(self.tmp.name)
        self.work = self.root / "work"
        self.work.mkdir()
        self.darling = self.root / "darling"
        (self.darling / "usr/lib").mkdir(parents=True)
        self.prefix = self.root / "prefix"
        self.out = self.root / "out"

    def scan(self, apps_root=None, attest=True):
        env = {"PATH": os.environ["PATH"], "APPS_ROOT": str(apps_root or self.prefix),
               "DARLING_ROOT": str(self.darling), "OUT_DIR": str(self.out)}
        if attest:
            env["APPS_ROOT_IS_DARLING_PREFIX"] = "1"
        return subprocess.run([sys.executable, "-I", str(SCRIPT)], env=env, capture_output=True, text=True)

    def report(self):
        return json.loads((self.out / "app-scan.json").read_text())

    def install(self, name, source_text, install_name=None, reexport=(), sysroot=None):
        install_name = install_name or "/usr/lib/" + name
        dylib(self.work / name, source_text, self.work, install_name, reexport, sysroot)
        shutil.copy(self.work / name, self.darling / "usr/lib" / name)

    def test_plain_arm64_app_reports_a_missing_symbol(self):
        dylib(self.work / "libfull.dylib", "int have(void){return 1;}\nint other(void){return 2;}\n",
              self.work, "/usr/lib/libfix.dylib")
        self.install("libfix.dylib", "int have(void){return 1;}\n")
        app(self.prefix, "Fix", "extern int have(void), other(void);\nint main(void){return have()+other();}\n",
            self.work, ["full"])
        result = self.scan()
        self.assertEqual(result.returncode, 0, result.stderr)
        row = self.report()["apps"][0]
        self.assertEqual(row["missing_syms"]["other"], {"libfix": 1})
        self.assertNotIn("fully resolvable at launch now: 1", (self.out / "app-scan.txt").read_text())

    def test_complete_library_resolves(self):
        self.install("libfix.dylib", "int have(void){return 1;}\n")
        app(self.prefix, "Fix", "extern int have(void);\nint main(void){return have();}\n", self.work, ["fix"])
        result = self.scan()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.report()["apps"][0]["missing_syms"], {"swift": {}, "other": {}})

    def test_unreadable_executable_is_an_error_not_resolvable(self):
        app(self.prefix, "Broken", "", self.work, [], corrupt=True)
        result = self.scan()
        self.assertEqual(result.returncode, 1)
        report = self.report()
        self.assertEqual(report["apps"], [])
        self.assertIn("Broken", report["errors"])
        self.assertNotIn("Broken", (self.out / "app-scan.txt").read_text().splitlines()[0])

    def test_reexport_cycle_does_not_hide_exports(self):
        # A re-exports B and B re-exports A. The linker refuses to build that directly, so B is linked
        # against a temporary A that re-exports a differently named copy of B.
        sdk = self.root / "sdk"
        (sdk / "usr/lib").mkdir(parents=True)
        dylib(sdk / "usr/lib/libBx.dylib", "int inB(void){return 1;}\n", self.work, "/usr/lib/libBx.dylib")
        dylib(sdk / "usr/lib/libA.dylib", "int inA(void){return 1;}\n", self.work, "/usr/lib/libA.dylib",
              [sdk / "usr/lib/libBx.dylib"], sdk)
        self.install("libB0.dylib", "int inB(void){return 1;}\n", "/usr/lib/libB.dylib")
        self.install("libA.dylib", "int inA(void){return 1;}\n", reexport=[self.work / "libB0.dylib"],
                     sysroot=self.darling)
        self.install("libB.dylib", "int inB(void){return 1;}\n", reexport=[sdk / "usr/lib/libA.dylib"], sysroot=sdk)
        app(self.prefix, "A1", "extern int inB(void);\nint main(void){return inB();}\n", self.work, ["A"])
        app(self.prefix, "B1", "extern int inA(void);\nint main(void){return inA();}\n", self.work, ["B"])
        result = self.scan()
        self.assertEqual(result.returncode, 0, result.stderr)
        for row in self.report()["apps"]:
            self.assertEqual(row["missing_syms"], {"swift": {}, "other": {}}, row["app"])

    def test_macos_volume_root_is_refused(self):
        (self.prefix / "System/Applications").mkdir(parents=True)
        (self.prefix / "Applications").mkdir()
        result = self.scan()
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("macOS volume root", result.stderr)
        self.assertFalse(self.out.exists())

    def test_root_without_attestation_is_refused(self):
        (self.prefix / "Applications").mkdir(parents=True)
        result = self.scan(attest=False)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("APPS_ROOT_IS_DARLING_PREFIX", result.stderr)


if __name__ == "__main__":
    unittest.main()
