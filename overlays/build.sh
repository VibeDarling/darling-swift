#!/bin/sh
# Build the arm64 slices of the Swift SDK overlays in this directory and merge them with the
# x86_64 slices already in the repository (Swift 5.2.2 builds from swift.org).
#
# Required environment:
#   SWIFT_TOOLCHAIN     usr/ directory of a Swift 6.3.3 toolchain (the Linux release works)
#   SWIFT_RESOURCE_DIR  usr/lib/swift from swift-6.3.3-RELEASE-osx.pkg (Swift/_Concurrency modules, shims, clang headers)
#   DARLING_SDK         Darling's MacOSX.sdk, including the Clang module maps and API notes for
#                       Darwin, ObjectiveC, Dispatch, os, CoreFoundation and the sys/cdefs.h default-platform fix
#   DARLING_LD          Darling's ld64 (build/src/external/cctools-port/cctools/ld64/src/aarch64-apple-darwin20-ld)
#   DARLING_LIBSYSTEM   Darling's built libSystem.B.dylib
#   DARLING_ROOT        installed Darling root (libexec/darling): libobjc and CoreFoundation are linked from it
# Optional:
#   LD_EXTRA_FLAGS      extra ld64 flags, e.g. the -dylib_file mappings Darling's own executables link with
set -eu

here=$(cd "$(dirname "$0")" && pwd)
repo=$(cd "$here/.." && pwd)
: "${SWIFT_TOOLCHAIN:?}" "${SWIFT_RESOURCE_DIR:?}" "${DARLING_SDK:?}" "${DARLING_LD:?}" "${DARLING_LIBSYSTEM:?}" "${DARLING_ROOT:?}"
LD_EXTRA_FLAGS=${LD_EXTRA_FLAGS:-}
out="$here/build"
mkdir -p "$out/modules" "$out/obj"

# build_module <Module> <sources...> [-- <extra swiftc -frontend flags>] [--link <extra ld inputs>]
build_module() {
	module=$1
	shift
	sources=""
	swift_flags=""
	link_inputs=""
	mode=src
	for arg in "$@"; do
		case "$arg" in
			--) mode=flags ;;
			--link) mode=link ;;
			*) case "$mode" in
				src) sources="$sources $arg" ;;
				flags) swift_flags="$swift_flags $arg" ;;
				link) link_inputs="$link_inputs $arg" ;;
			esac ;;
		esac
	done

	# Library evolution, like Apple's SDK overlays, so binaries built against the macOS SDK use the same access patterns.
	# shellcheck disable=SC2086
	"$SWIFT_TOOLCHAIN/bin/swiftc" -frontend -c $sources \
		-target arm64-apple-macosx26.0 -sdk "$DARLING_SDK" -resource-dir "$SWIFT_RESOURCE_DIR" \
		-module-cache-path "$out/module-cache" -swift-version 5 \
		-module-name "$module" -module-link-name "swift$module" -autolink-force-load \
		-enable-library-evolution -parse-as-library -O \
		-I "$out/modules" \
		-Xcc -fmodule-map-file="$here/shims/overlay-shims.modulemap" \
		-emit-module-path "$out/modules/$module.swiftmodule" \
		-o "$out/obj/$module.o" $swift_flags

	# shellcheck disable=SC2086
	"$DARLING_LD" -dylib -arch arm64 -platform_version macos 26.0 26.0 -syslibroot "$DARLING_SDK" \
		-install_name "/usr/lib/swift/libswift$module.dylib" \
		-compatibility_version 1.0.0 -current_version 1.0.0 \
		$LD_EXTRA_FLAGS \
		-L "$SWIFT_RESOURCE_DIR/macosx" -L "$out" \
		"$out/obj/$module.o" "$DARLING_LIBSYSTEM" "$DARLING_ROOT/usr/lib/libobjc.A.dylib" \
		-lswiftCore $link_inputs \
		-o "$out/libswift$module.dylib"
}

corefoundation="$DARLING_ROOT/System/Library/Frameworks/CoreFoundation.framework/Versions/A/CoreFoundation"

build_module Darwin "$here"/Darwin/*.swift
build_module ObjectiveC "$here/ObjectiveC/ObjectiveC.swift" -- -disable-objc-attr-requires-foundation-module --link -lswiftDarwin
build_module CoreFoundation "$here"/CoreFoundation/*.swift --link "$corefoundation" -lswiftDarwin
"$SWIFT_TOOLCHAIN/bin/clang++" -target arm64-apple-macosx26.0 -isysroot "$DARLING_SDK" -I "$here/Dispatch/include" \
	-std=c++17 -fobjc-arc -O2 -c "$here/Dispatch/Dispatch.mm" -o "$out/obj/Dispatch.mm.o"
"$SWIFT_TOOLCHAIN/bin/clang" -target arm64-apple-macosx26.0 -isysroot "$DARLING_SDK" -fobjc-arc -O2 \
	-c "$here/Dispatch/DarlingSerialExecutor.m" -o "$out/obj/DarlingSerialExecutor.m.o"
build_module Dispatch "$here"/Dispatch/*.swift --link "$out/obj/Dispatch.mm.o" "$out/obj/DarlingSerialExecutor.m.o" -lswiftObjectiveC -lswiftDarwin
build_module os "$here/os/os.swift" -- -Xcc -fmodule-map-file="$here/os/shims/module.modulemap" --link -lswiftDarwin -lswiftObjectiveC -lswiftDispatch
build_module XPC "$here/XPC/XPC.swift" -- -Xcc -fmodule-map-file="$here/XPC/shims/module.modulemap" --link -lswiftDarwin -lswiftObjectiveC -lswiftDispatch

# Intentionally partial: String, Array, Dictionary and Set bridging only (see README).
foundation="$DARLING_ROOT/System/Library/Frameworks/Foundation.framework/Versions/C/Foundation"
build_module Foundation "$here"/Foundation/*.swift --link "$foundation" "$corefoundation" -lswiftDarwin -lswiftObjectiveC -lswiftCoreFoundation -lswiftDispatch

coregraphics="$DARLING_ROOT/System/Library/Frameworks/CoreGraphics.framework/Versions/A/CoreGraphics"
build_module CoreGraphics "$here/CoreGraphics/CoreGraphics.swift" -- -Xcc -fmodule-map-file="$here/CoreGraphics/shims/module.modulemap" --link "$coregraphics" "$corefoundation" -lswiftCoreFoundation -lswiftDarwin

# Minimal clean-room AppKit overlay (see README).
appkit="$DARLING_ROOT/System/Library/Frameworks/AppKit.framework/Versions/C/AppKit"
build_module AppKit "$here/AppKit/AppKit.swift" -- -Xcc -fmodule-map-file="$here/AppKit/shims/module.modulemap" -Xcc -fmodule-map-file="$here/CoreGraphics/shims/module.modulemap" --link "$appkit" "$foundation" -lswiftFoundation -lswiftCoreGraphics -lswiftCoreFoundation -lswiftObjectiveC -lswiftDarwin

# Minimal clean-room QuartzCore overlay (see README).
build_module QuartzCore "$here/QuartzCore/QuartzCore.swift" -- -Xcc -fmodule-map-file="$here/QuartzCore/shims/module.modulemap"

# Intentionally partial: the vector and matrix conversions and SCNBoundingVolume only (see README).
scenekit="$DARLING_ROOT/System/Library/Frameworks/SceneKit.framework/Versions/A/SceneKit"
build_module SceneKit "$here/SceneKit/SceneKit.swift" -- -Xcc -fmodule-map-file="$here/SceneKit/shims/module.modulemap" -Xcc -fmodule-map-file="$here/CoreGraphics/shims/module.modulemap" --link "$scenekit" "$foundation" "$corefoundation" -lswiftFoundation -lswiftCoreGraphics -lswiftCoreFoundation -lswiftObjectiveC -lswiftDarwin

# Combine: OpenCombine built as module `Combine`, so its mangled names match what apps import.
# Unlike the overlays above this is a framework binary, not a /usr/lib/swift dylib, and it has no
# x86_64 slice to merge with. See overlays/README.md.
#
# Its .swiftmodule deliberately goes somewhere the overlays above do NOT import from. They pass
# -I "$out/modules", and two vendored sources here are guarded on `#if !canImport(Combine)`,
# so a Combine module on that path would silently change what the other overlays compile on every
# run after the first. An overlay that genuinely needs Combine (Dispatch's Scheduler conformance)
# should add -I "$out/modules-combine" explicitly.
mkdir -p "$out/modules-combine"
"$SWIFT_TOOLCHAIN/bin/clang" -target arm64-apple-macosx26.0 -isysroot "$DARLING_SDK" \
	-I "$here/Combine/include" -Wall -Wextra -O2 -fvisibility=hidden \
	-c "$here/Combine/helpers.c" -o "$out/obj/CombineHelpers.o"

# shellcheck disable=SC2086
"$SWIFT_TOOLCHAIN/bin/swiftc" -frontend -c $(find "$here/Combine/Sources" -name '*.swift' | sort) \
	-target arm64-apple-macosx26.0 -sdk "$DARLING_SDK" -resource-dir "$SWIFT_RESOURCE_DIR" \
	-module-cache-path "$out/module-cache" -swift-version 5 \
	-module-name Combine \
	-enable-library-evolution -parse-as-library -O \
	-Xcc -fmodule-map-file="$here/Combine/include/module.modulemap" \
	-emit-module-path "$out/modules-combine/Combine.swiftmodule" \
	-o "$out/obj/Combine.o"

mkdir -p "$repo/Combine.framework/Versions/A"
# shellcheck disable=SC2086
"$DARLING_LD" -dylib -arch arm64 -platform_version macos 26.0 26.0 -syslibroot "$DARLING_SDK" \
	-install_name "/System/Library/Frameworks/Combine.framework/Versions/A/Combine" \
	-compatibility_version 1.0.0 -current_version 1.0.0 \
	$LD_EXTRA_FLAGS \
	-L "$SWIFT_RESOURCE_DIR/macosx" \
	"$out/obj/Combine.o" "$out/obj/CombineHelpers.o" \
	"$DARLING_LIBSYSTEM" "$DARLING_ROOT/usr/lib/libobjc.A.dylib" \
	-lswiftCore \
	-o "$repo/Combine.framework/Versions/A/Combine"
echo "updated Combine.framework: $(llvm-lipo -archs "$repo/Combine.framework/Versions/A/Combine")"

# CryptoKit: Apple's is closed source and pure Swift. swift-crypto deliberately mirrors its public
# API, so building it as module `CryptoKit` makes the mangled names match what apps import. Darling
# cannot link BoringSSL into this framework, so the fork below supplies a pure-Swift SHA-256 and
# neutralises the `canImport(CryptoKit)` guards that would otherwise collapse the package into an
# empty module re-exporting itself. See overlays/README.md and the fork's DARLING-CHANGES.md.
#
# Pinned BY COMMIT on purpose: a branch reference would make this build non-reproducible.
CRYPTOKIT_FORK_URL=${CRYPTOKIT_FORK_URL:-https://github.com/cristim/swift-crypto.git}
CRYPTOKIT_FORK_COMMIT=${CRYPTOKIT_FORK_COMMIT:-c4105ade5fbe6866375ec65146cac733d53a1146}
crypto_src="$out/swift-crypto"
if [ ! -d "$crypto_src/.git" ]; then
	git clone --quiet --filter=blob:none "$CRYPTOKIT_FORK_URL" "$crypto_src"
fi
git -C "$crypto_src" fetch --quiet origin "$CRYPTOKIT_FORK_COMMIT" \
	|| git -C "$crypto_src" fetch --quiet origin
git -C "$crypto_src" checkout --quiet --detach "$CRYPTOKIT_FORK_COMMIT"

# SHA-256 and HMAC-SHA-256 only: that is what the corpus binds. See overlays/README.md.
cryptokit_sources="
	Sources/Crypto/Digests/Digest.swift
	Sources/Crypto/Digests/Digests.swift
	Sources/Crypto/Digests/HashFunctions.swift
	Sources/Crypto/Digests/HashFunctions_SHA2.swift
	Sources/Crypto/Digests/Darling/Digest_darling.swift
	Sources/Crypto/Keys/Symmetric/SymmetricKeys.swift
	Sources/Crypto/Insecure/Insecure.swift
	Sources/Crypto/Util/ArraySpanHelpers.swift
	Sources/Crypto/Util/Data+ArraySpan.swift
	Sources/Crypto/Util/PrettyBytes.swift
	Sources/Crypto/Util/SafeCompare.swift
	Sources/Crypto/Util/SecureBytes.swift
	Sources/Crypto/Util/Zeroization.swift
	Sources/Crypto/Util/BoringSSL/SafeCompare_boring.swift
	Sources/Crypto/Util/BoringSSL/RNG_boring.swift
	Sources/Crypto/Util/BoringSSL/InlineArray+withBytes_boring.swift
	Sources/Crypto/Util/BoringSSL/Optional+withUnsafeBytes_boring.swift
"
cryptokit_files=""
for f in $cryptokit_sources; do
	cryptokit_files="$cryptokit_files $crypto_src/$f"
done
# These three live in a directory whose name contains spaces, so they are passed separately.
mac_dir="$crypto_src/Sources/Crypto/Message Authentication Codes"

mkdir -p "$out/modules-cryptokit"
# shellcheck disable=SC2086
"$SWIFT_TOOLCHAIN/bin/swiftc" -frontend -c $cryptokit_files \
	"$mac_dir/HMAC/HMAC.swift" "$mac_dir/MessageAuthenticationCode.swift" "$mac_dir/MACFunctions.swift" \
	-target arm64-apple-macosx26.0 -sdk "$DARLING_SDK" -resource-dir "$SWIFT_RESOURCE_DIR" \
	-module-cache-path "$out/module-cache" -swift-version 5 \
	-module-name CryptoKit \
	-D DARLING_CRYPTOKIT_MODULE -enable-experimental-feature Lifetimes \
	-enable-library-evolution -parse-as-library -O \
	-I "$out/modules" \
	-Xcc -fmodule-map-file="$here/shims/overlay-shims.modulemap" \
	-emit-module-path "$out/modules-cryptokit/CryptoKit.swiftmodule" \
	-o "$out/obj/CryptoKit.o"

mkdir -p "$repo/CryptoKit.framework/Versions/A"
# shellcheck disable=SC2086
"$DARLING_LD" -dylib -arch arm64 -platform_version macos 26.0 26.0 -syslibroot "$DARLING_SDK" \
	-install_name "/System/Library/Frameworks/CryptoKit.framework/Versions/A/CryptoKit" \
	-compatibility_version 1.0.0 -current_version 1.0.0 \
	$LD_EXTRA_FLAGS \
	-L "$SWIFT_RESOURCE_DIR/macosx" -L "$out" \
	"$out/obj/CryptoKit.o" \
	"$DARLING_LIBSYSTEM" "$DARLING_ROOT/usr/lib/libobjc.A.dylib" \
	-lswiftCore -lswiftFoundation -lswiftCoreFoundation -lswiftDarwin -lswiftObjectiveC \
	-o "$repo/CryptoKit.framework/Versions/A/CryptoKit"
echo "updated CryptoKit.framework: $(llvm-lipo -archs "$repo/CryptoKit.framework/Versions/A/CryptoKit")"

for module in Darwin ObjectiveC CoreFoundation Dispatch os XPC Foundation CoreGraphics AppKit QuartzCore SceneKit; do
	dylib="libswift$module.dylib"
	llvm-lipo -thin x86_64 "$repo/$dylib" -output "$out/$dylib.x86_64" 2>/dev/null || cp "$repo/$dylib" "$out/$dylib.x86_64"
	llvm-lipo -create "$out/$dylib.x86_64" "$out/$dylib" -output "$repo/$dylib"
	rm "$out/$dylib.x86_64"
	echo "updated $dylib: $(llvm-lipo -archs "$repo/$dylib")"
done
