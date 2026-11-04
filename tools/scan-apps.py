#!/usr/bin/env python3
"""Arch-aware load check of guest app binaries against Darling + the Swift pieces built here.

Demand analysis only (AGENTS.md ladder rung 5, "Binaries you may point tools at"): it reads which
libraries a guest application loads and which symbols it imports, with llvm-lipo, llvm-objdump
--dylibs-used and llvm-nm. APPS_ROOT must be a directory inside a Darling prefix that holds
Applications/. A macOS volume root (System/Applications/) is refused, and so is any root not
attested with APPS_ROOT_IS_DARLING_PREFIX=1: never point this at a binary from a macOS install.

For the executable of each app bundle plus the in-bundle images dyld binds at launch (the
transitive closure of non-weak in-bundle dependencies) it resolves each non-weak dependency to
a file in:
  1. the bundle itself (@loader_path / @rpath / @executable_path), 2. overlays/out (arm64 Swift
overlays built here), 3. the Swift 6.3.3 runtime, 4. the Darling root.
A dependency counts as present only if the file has an arm64 (or arm64e) slice. Each image is read
with its own slice (arm64e, else arm64). Then it checks every non-weak imported symbol against the
exports of the arm64 slice of the library it's bound to (two-level namespace). PlugIns, XPCServices,
Helpers and .appex images are dlopen'd on demand and reported only as deferred.

A tool that exits non-zero, a missing slice or an unresolvable re-export is an error for that app:
the app is listed as errored, never as resolvable, and the script exits 1.

Categories per missing item:
  swift    - a /usr/lib/swift library, or a Swift-mangled ($s...) symbol from any library
  other    - everything else
Output: $OUT_DIR/$OUT_PREFIX.txt (table) and .json.

Environment:
  APPS_ROOT                 required; directory holding Applications/ inside a Darling prefix
  APPS_ROOT_IS_DARLING_PREFIX  must be 1; attests that APPS_ROOT is a Darling prefix
  DARLING_ROOT              Darling root to resolve against
  OUT_DIR                   output directory, default the current directory
  OUT_PREFIX                output basename, default app-scan
"""
import json, os, plistlib, subprocess, sys, collections

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
MAC = os.environ.get("APPS_ROOT")
if not MAC:
    sys.exit("APPS_ROOT is required: a directory inside a Darling prefix holding Applications/")
if os.environ.get("APPS_ROOT_IS_DARLING_PREFIX") != "1":
    sys.exit("refusing to run: set APPS_ROOT_IS_DARLING_PREFIX=1 to attest that APPS_ROOT is a Darling prefix, "
             "not a macOS install (AGENTS.md section 1)")
if os.path.isdir(os.path.join(MAC, "System/Applications")) or not os.path.isdir(os.path.join(MAC, "Applications")):
    sys.exit("APPS_ROOT must hold Applications/ and must not be a macOS volume root (System/Applications/)")
DARLING = os.environ.get("DARLING_ROOT", "/usr/local/libexec/darling")
OUT_PREFIX = os.environ.get("OUT_PREFIX", "app-scan")
OUT_DIR = os.environ.get("OUT_DIR", os.getcwd())
SEARCH_SWIFT = [os.path.join(ROOT, "overlays/out"), os.path.join(ROOT, "osx-6.3.3/payload/usr/lib/swift/macosx")]
EXTRA = sys.argv[1:]  # extra directories with /usr/lib/swift-style dylibs, searched first

MACHO_MAGICS = (b"\xfe\xed\xfa\xce", b"\xfe\xed\xfa\xcf", b"\xce\xfa\xed\xfe", b"\xcf\xfa\xed\xfe",
                b"\xca\xfe\xba\xbe", b"\xbe\xba\xfe\xca", b"\xca\xfe\xba\xbf", b"\xbf\xba\xfe\xca")

def is_macho(path):
    try:
        with open(path, "rb") as f:
            return f.read(4) in MACHO_MAGICS
    except OSError:
        return False

class ScanError(Exception):
    pass

def bundle_exe(app):
    try:
        exe = os.path.join(app, "Contents/MacOS",
                           plistlib.load(open(os.path.join(app, "Contents/Info.plist"), "rb"))["CFBundleExecutable"])
        return exe if os.path.isfile(exe) else None
    except (OSError, KeyError, plistlib.InvalidFileException):
        return None

def bundle_images(app):
    """Every Mach-O inside the bundle."""
    images = []
    for dirpath, _dirs, files in os.walk(app):
        for name in files:
            full = os.path.join(dirpath, name)
            if os.path.isfile(full) and is_macho(full):
                images.append(full)
    return sorted(images)

def load_time_images(app, images):
    """Images dyld binds at launch: the executable plus the transitive closure of
    its non-weak dependencies that live inside the bundle.

    PlugIns, XPCServices, Helpers, Library and .appex bundles are dlopen'd on
    demand, so their unresolved symbols cannot stop the app from starting.
    Counting them as blockers is what makes a bundle-wide walk over-report.
    """
    exe = bundle_exe(app)
    if not exe:
        raise ScanError(f"{app}: no readable Info.plist CFBundleExecutable, executable unknown")
    inside = set(os.path.realpath(i) for i in images)
    seen, queue = {os.path.realpath(exe)}, [exe]
    while queue:
        image = queue.pop()
        for install, weak in deps_of(image):
            if weak:
                continue
            dirs = [os.path.dirname(image), os.path.join(app, "Contents/MacOS"),
                    os.path.join(app, "Contents/Frameworks")]
            dep = resolve(install, dirs)
            if dep and dep in inside and dep not in seen:
                seen.add(dep)
                queue.append(dep)
    return [i for i in images if os.path.realpath(i) in seen]

def run(*args):
    result = subprocess.run(args, capture_output=True, text=True)
    if result.returncode != 0:
        raise ScanError(f"{' '.join(args)} exited {result.returncode}: {result.stderr.strip()}")
    return result.stdout

_arch_cache = {}
def archs(path):
    if path not in _arch_cache:
        out = run("llvm-lipo", "-archs", path).split()
        if not out:
            raise ScanError(f"llvm-lipo reported no architectures for {path}")
        _arch_cache[path] = out
    return _arch_cache[path]

def slice_of(path, prefer=("arm64e", "arm64")):
    """The slice to read for an image, chosen from the file; None when it has no arm64 slice."""
    available = archs(path)
    return next((a for a in prefer if a in available), None)

def has_arm64(path):
    return any(a in ("arm64", "arm64e") for a in archs(path))

_exp_cache = {}
def exports(path):
    """Exports of path plus everything it re-exports, followed through cycles (Foundation <-> CoreFoundation)."""
    if path not in _exp_cache:
        syms, seen, queue = set(), set(), [path]
        while queue:
            lib = queue.pop()
            if lib in seen:
                continue
            seen.add(lib)
            arch = slice_of(lib, ("arm64", "arm64e"))
            if arch is None:
                raise ScanError(f"{lib} has no arm64 slice")
            syms |= set(run("llvm-nm", "-gUj", f"--arch={arch}", lib).split())
            for line in run("llvm-objdump", "--macho", f"--arch={arch}", "--dylibs-used", lib).splitlines()[1:]:
                if "reexport" in line:
                    install = line.strip().split(" (")[0]
                    dep = resolve(install, [os.path.dirname(lib)])
                    if dep is None:
                        raise ScanError(f"cannot resolve re-export {install} of {lib}")
                    queue.append(dep)
        _exp_cache[path] = syms
    return _exp_cache[path]

def resolve(install, search_dirs=()):
    if install.startswith(("@loader_path/", "@executable_path/", "@rpath/")):
        rest = install.split("/", 1)[1]
        for d in search_dirs:
            p = os.path.join(d, rest)
            if os.path.exists(p):
                return os.path.realpath(p)
        return None
    if install.startswith("/usr/lib/swift/"):
        name = install.split("/")[-1]
        for base in EXTRA + SEARCH_SWIFT:
            p = os.path.join(base, name)
            if os.path.exists(p) and has_arm64(p):
                return p
        p = DARLING + install
        return p if os.path.exists(p) else None
    for cand in (DARLING + install,
                 DARLING + install.replace("/Versions/A/", "/").replace("/Versions/C/", "/")):
        if os.path.exists(cand):
            return os.path.realpath(cand)
    return None

def is_swift_lib(install):
    return install.startswith("/usr/lib/swift/")

def deps_of(image):
    deps = []
    arch = slice_of(image)
    if arch is None:
        raise ScanError(f"{image} has no arm64 slice")
    for line in run("llvm-objdump", "--macho", f"--arch={arch}", "--dylibs-used", image).splitlines():
        line = line.strip()
        if not line or line.endswith("):") or not (line.startswith(("/usr/", "/System/", "@"))):
            continue
        deps.append((line.split(" (")[0], "weak)" in line))
    return deps

def scan_app(a, ap):
    images = bundle_images(ap)
    if not images:
        return None
    load = load_time_images(ap, images)
    lazy = [i for i in images if i not in load]
    search_dirs = [os.path.join(ap, "Contents/MacOS"), os.path.join(ap, "Contents/Frameworks"),
                   os.path.join(ap, "Contents/Library"), os.path.join(ap, "Contents/PlugIns"),
                   os.path.join(ap, "Contents/XPCServices"), os.path.join(ap, "Contents/Helpers")]
    missing_libs = {"swift": [], "other": []}
    missing_syms = {"swift": collections.Counter(), "other": collections.Counter()}
    all_deps = []
    for image in load:
        search_dirs.append(os.path.dirname(image))
        deps = deps_of(image)
        all_deps += deps
        bound = {}
        for install, weak in deps:
            p = resolve(install, search_dirs)
            short = install.split("/")[-1]
            bound[short] = p if (p and has_arm64(p)) else None
            if weak:
                continue
            if p is None:
                missing_libs["swift" if is_swift_lib(install) else "other"].append(short)
            elif not has_arm64(p):
                missing_libs["swift" if is_swift_lib(install) else "other"].append(short + " (x86_64-only)")
        for line in run("llvm-nm", "-um", f"--arch={slice_of(image)}", image).splitlines():
            parts = line.split()
            if "(from" not in parts:
                continue
            i = parts.index("(from")
            if "weak" in parts[:i - 1]:  # nm's weak flag, not a symbol name containing "weak"
                continue
            sym, lib = parts[i - 1], parts[i + 1].rstrip(")")
            libfile = bound.get(lib) or bound.get(lib + ".dylib")
            if libfile is None:
                continue  # already counted as a missing library
            if sym in exports(libfile):
                continue
            kind = "swift" if (lib.startswith("libswift") or sym.startswith("_$s")) else "other"
            missing_syms[kind][lib] += 1
    for key in missing_libs:
        missing_libs[key] = sorted(set(missing_libs[key]))
    return {
        "app": a[:-4],
        "images": len(images),
        "load_time_images": len(load),
        "deferred_images": len(lazy),
        "swift_linking": any(is_swift_lib(d) for d, _ in all_deps),
        "missing_libs": missing_libs,
        "missing_syms": {k: dict(v) for k, v in missing_syms.items()},
    }


errors = {}
rows = []
for base in ["Applications", "Applications/Utilities"]:
    if not os.path.isdir(os.path.join(MAC, base)):
        continue
    for a in sorted(os.listdir(os.path.join(MAC, base))):
        if not a.endswith(".app"):
            continue
        ap = os.path.join(MAC, base, a)
        try:
            row = scan_app(a, ap)
        except ScanError as e:
            errors[a[:-4]] = str(e)
        else:
            if row:
                rows.append(row)

def n_other(r):
    return len(r["missing_libs"]["other"]) + sum(r["missing_syms"]["other"].values())
def n_swift(r):
    return len(r["missing_libs"]["swift"]) + sum(r["missing_syms"]["swift"].values())

rows.sort(key=lambda r: (n_other(r), n_swift(r)))
os.makedirs(OUT_DIR, exist_ok=True)
json.dump({"apps": rows, "errors": errors}, open(os.path.join(OUT_DIR, f"{OUT_PREFIX}.json"), "w"), indent=1)
with open(os.path.join(OUT_DIR, f"{OUT_PREFIX}.txt"), "w") as f:
    loadable = [r["app"] for r in rows if n_other(r) == 0 and n_swift(r) == 0]
    swift_only = [r["app"] for r in rows if n_other(r) == 0 and n_swift(r) > 0]
    f.write(f"apps: {len(rows)}; fully resolvable at launch now: {len(loadable)} {loadable}\n")
    f.write(f"blocked only by Swift pieces: {len(swift_only)} {swift_only}\n")
    f.write("counts cover load-time images only (executable + non-weak in-bundle deps); "
            "PlugIns/XPCServices/Helpers/.appex are dlopen'd and cannot block a launch\n")
    f.write(f"errored (not scanned, never counted as resolvable): {len(errors)}\n")
    for app, message in sorted(errors.items()):
        f.write(f"  ERROR {app}: {message}\n")
    f.write("other_items swift_items app | other missing libs | swift missing libs | other syms by lib | swift syms by lib\n")
    for r in rows:
        fmt = lambda c: ", ".join(f"{k}:{v}" for k, v in sorted(c.items(), key=lambda kv: -kv[1])[:6])
        f.write(f"{n_other(r):5d} {n_swift(r):5d} {r['app']} | {', '.join(r['missing_libs']['other'][:5])} | "
                f"{', '.join(r['missing_libs']['swift'][:6])} | {fmt(r['missing_syms']['other'])} | {fmt(r['missing_syms']['swift'])}\n")
print(open(os.path.join(OUT_DIR, f"{OUT_PREFIX}.txt")).read())
sys.exit(1 if errors else 0)
