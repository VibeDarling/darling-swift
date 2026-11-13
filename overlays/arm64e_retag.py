#!/usr/bin/env python3
"""Relabel Mach-O files so Darling's ld64 links an arm64e overlay from build.sh (DARLING_SWIFT_ARCH=arm64e).

  arm64e_retag.py object IN OUT   clear the versioned-ABI caps byte clang and swiftc stamp on arm64e objects.
                                  ld64 does not know the byte and reads such an object as plain arm64.
  arm64e_retag.py dylib IN OUT    write IN's arm64 slice (IN may be universal) labelled arm64e; an arm64e IN is copied. The overlays link
                                  against arm64 dylibs; ld64 reads only the export trie and load commands of a
                                  dylib it links against, so the relabelled copy stands in for a real arm64e one.

Constants: CPU_SUBTYPE_ARM64E (2) and the capability mask (CPU_SUBTYPE_MASK, 0xff000000) are in xnu osfmk/mach/machine.h
(rung 1). The script reads only Mach-O header fields and the fat table of Darling's own build output and of the
Swift toolchain libraries the arm64 build already links; it never parses an Apple macOS-install binary.

Run with python3 -I. The input is validated and never modified.
"""
import struct
import sys

MH_MAGIC_64 = 0xFEEDFACF
FAT_MAGIC = 0xCAFEBABE  # big endian
CPU_TYPE_ARM64 = 0x0100000C
CPU_SUBTYPE_ARM64, CPU_SUBTYPE_ARM64E = 0, 2
CAPS_MASK = 0xFF000000
MH_OBJECT, MH_DYLIB = 1, 6


def arm64_slice(data):
    """The arm64 (subtype 0) Mach-O in `data`, which is either thin or a fat file."""
    if struct.unpack_from(">I", data, 0)[0] != FAT_MAGIC:
        return data
    count = struct.unpack_from(">I", data, 4)[0]
    for i in range(count):
        cputype, subtype, offset, size, _align = struct.unpack_from(">iiIII", data, 8 + 20 * i)
        if cputype == CPU_TYPE_ARM64 and subtype & ~CAPS_MASK == CPU_SUBTYPE_ARM64:
            return data[offset:offset + size]
    raise SystemExit("no arm64 slice in the fat file")


def header(data):
    if len(data) < 32:
        raise SystemExit("too short for a Mach-O header")
    magic, cputype, subtype, filetype = struct.unpack_from("<IIII", data, 0)
    if magic != MH_MAGIC_64 or cputype != CPU_TYPE_ARM64:
        raise SystemExit("not a 64-bit arm64 Mach-O")
    return subtype, filetype


def main(argv):
    if len(argv) != 4 or argv[1] not in ("object", "dylib"):
        raise SystemExit(__doc__)
    kind, src, dst = argv[1:]
    data = open(src, "rb").read()
    if kind == "dylib":
        data = arm64_slice(data)
    subtype, filetype = header(data)
    if kind == "object":
        if filetype != MH_OBJECT or subtype != 0x80000000 | CPU_SUBTYPE_ARM64E:
            raise SystemExit("%s: not an arm64e object with the caps byte (subtype 0x%08x)" % (src, subtype))
    elif filetype != MH_DYLIB or subtype & ~CAPS_MASK not in (CPU_SUBTYPE_ARM64, CPU_SUBTYPE_ARM64E):
        raise SystemExit("%s: not an arm64 or arm64e dylib" % src)
    out = bytearray(data)
    struct.pack_into("<I", out, 8, CPU_SUBTYPE_ARM64E)
    open(dst, "wb").write(out)


main(sys.argv)
