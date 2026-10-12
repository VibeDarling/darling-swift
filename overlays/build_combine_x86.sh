#!/bin/bash
# Build the x86_64 slice of Combine.framework from OpenCombine (MIT)
# and merge it with the arm64 slice into a universal binary.
#
# Environment variables:
#   SWIFT_TOOLCHAIN     usr/ directory of a Swift 6.3.3 toolchain (e.g. Linux release from swift.org)
#   SWIFT_RESOURCE_DIR  usr/lib/swift from swift-6.3.3-RELEASE-osx.pkg
#   DARLING_SDK         Darling's MacOSX.sdk
#   DARLING_LD          Darling's ld64 (x86_64-apple-darwin20-ld)
#   DARLING_LIBSYSTEM   Darling's built libSystem.B.dylib
#   DARLING_ROOT        installed Darling root (libexec/darling)
set -euo pipefail

here=$(cd "$(dirname "$0")" && pwd)
repo=$(cd "$here/.." && pwd)

: "${SWIFT_TOOLCHAIN:?}" "${SWIFT_RESOURCE_DIR:?}" "${DARLING_SDK:?}" "${DARLING_LD:?}" "${DARLING_LIBSYSTEM:?}" "${DARLING_ROOT:?}"

out="$here/build-x86"
rm -rf "$out"
mkdir -p "$out/modules" "$out/obj"

OPENCOMBINE_URL=${OPENCOMBINE_URL:-https://github.com/cristim/OpenCombine.git}
OPENCOMBINE_COMMIT=${OPENCOMBINE_COMMIT:-10df981a64800643559490d72174f43438562e73}
opencombine_src=${OPENCOMBINE_SRC:-$out/OpenCombine}

if [ -z "${OPENCOMBINE_SRC:-}" ]; then
	if [ ! -d "$opencombine_src/.git" ]; then
		git clone --quiet --filter=blob:none "$OPENCOMBINE_URL" "$opencombine_src"
	fi
	git -C "$opencombine_src" fetch --quiet origin "$OPENCOMBINE_COMMIT" \
		|| git -C "$opencombine_src" fetch --quiet origin
	git -C "$opencombine_src" checkout --quiet --detach "$OPENCOMBINE_COMMIT"
fi

rm -rf "$out/combine-src"
cp -R "$opencombine_src/Sources/OpenCombine" "$out/combine-src"
for p in "$here"/Combine/patches/*.patch; do
	patch -p1 -s -d "$out/combine-src" < "$p"
done

"$SWIFT_TOOLCHAIN/bin/clang" -target x86_64-apple-macosx26.0 -isysroot "$DARLING_SDK" \
	-I "$opencombine_src/Sources/COpenCombineHelpers/include" -Wall -Wextra -O2 -fvisibility=hidden \
	-c "$here/Combine/helpers.c" -o "$out/obj/CombineHelpers.o"

: > "$out/Combine.sources"
find "$out/combine-src" -name '*.swift' | LC_ALL=C sort | while IFS= read -r f; do
	printf '"%s"\n' "$(printf '%s' "$f" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g')" >> "$out/Combine.sources"
done

"$SWIFT_TOOLCHAIN/bin/swiftc" -frontend -c @"$out/Combine.sources" \
	-target x86_64-apple-macosx26.0 -sdk "$DARLING_SDK" -resource-dir "$SWIFT_RESOURCE_DIR" \
	-module-cache-path "$out/module-cache" -swift-version 5 \
	-module-name Combine \
	-enable-library-evolution -parse-as-library -O \
	-Xcc -fmodule-map-file="$opencombine_src/Sources/COpenCombineHelpers/include/module.modulemap" \
	-emit-module-path "$out/modules/Combine.swiftmodule" \
	-o "$out/obj/Combine.o"

mkdir -p "$repo/Combine.framework/Versions/A"

"$DARLING_LD" -dylib -arch x86_64 -platform_version macos 26.0 26.0 -syslibroot "$DARLING_SDK" \
	-install_name "/System/Library/Frameworks/Combine.framework/Versions/A/Combine" \
	-compatibility_version 1.0.0 -current_version 1.0.0 \
	-L "$SWIFT_RESOURCE_DIR/macosx" \
	"$out/obj/Combine.o" "$out/obj/CombineHelpers.o" \
	"$DARLING_LIBSYSTEM" "$DARLING_ROOT/usr/lib/libobjc.A.dylib" \
	-lswiftCore \
	-o "$out/Combine.x86_64"

# If arm64 slice exists, create universal fat binary
if [ -f "$repo/Combine.framework/Versions/A/Combine" ]; then
	llvm-lipo -thin arm64 "$repo/Combine.framework/Versions/A/Combine" -output "$out/Combine.arm64" 2>/dev/null || cp "$repo/Combine.framework/Versions/A/Combine" "$out/Combine.arm64"
	llvm-lipo -create "$out/Combine.arm64" "$out/Combine.x86_64" -output "$repo/Combine.framework/Versions/A/Combine"
else
	cp "$out/Combine.x86_64" "$repo/Combine.framework/Versions/A/Combine"
fi

echo "Updated Combine.framework: $(llvm-lipo -archs "$repo/Combine.framework/Versions/A/Combine")"
