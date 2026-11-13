#!/usr/bin/env python3
"""Host test for arm64e_retag.py on synthetic Mach-O headers: run with python3 overlays/tests/arm64e_retag_test.py."""
import os
import struct
import subprocess
import sys
import tempfile

here = os.path.dirname(os.path.abspath(__file__))
retag = os.path.join(here, "..", "arm64e_retag.py")
MAGIC, ARM64, OBJECT, DYLIB = 0xFEEDFACF, 0x0100000C, 1, 6
failures = 0


def check(condition, label):
    global failures
    print("ok:" if condition else "FAIL:", label)
    failures += not condition


def macho(subtype, filetype):
    return struct.pack("<IIIIIIII", MAGIC, ARM64, subtype, filetype, 0, 0, 0, 0)


def run(kind, data, directory):
    src, dst = os.path.join(directory, "in"), os.path.join(directory, "out")
    open(src, "wb").write(data)
    if os.path.exists(dst):
        os.remove(dst)
    result = subprocess.run([sys.executable, "-I", retag, kind, src, dst], capture_output=True)
    return result.returncode, (open(dst, "rb").read() if result.returncode == 0 else None)


with tempfile.TemporaryDirectory() as d:
    rc, out = run("object", macho(0x80000002, OBJECT), d)
    check(rc == 0 and struct.unpack_from("<I", out, 8)[0] == 2, "an arm64e object loses its caps byte")
    rc, _ = run("object", macho(0, OBJECT), d)
    check(rc != 0, "a plain arm64 object is rejected")
    rc, out = run("dylib", macho(0, DYLIB), d)
    check(rc == 0 and struct.unpack_from("<I", out, 8)[0] == 2, "an arm64 dylib is relabelled arm64e")
    thin = macho(0, DYLIB) + b"\0" * 8
    fat = struct.pack(">IIiiIII", 0xCAFEBABE, 1, ARM64, 0, 4096, len(thin), 12) + b"\0" * (4096 - 28) + thin
    rc, out = run("dylib", fat, d)
    check(rc == 0 and out is not None and struct.unpack_from("<I", out, 8)[0] == 2, "the arm64 slice of a fat file is relabelled")

sys.exit(1 if failures else 0)
