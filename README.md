# Darling Swift

Attention: This repository uses Git LFS!

Files found here come from official Swift releases from Swift.org. They are downloaded and extracted using the `build.sh` script before committing.

The runtime libraries (`libswiftCore`, `libswift_Concurrency`, `libswift_StringProcessing`, `libswiftObservation`, ...) come from the release in `version.txt` and are universal (arm64 and x86_64) binaries.

Swift.org toolchains no longer include the Darwin SDK overlays (`libswiftAppKit`, `libswiftFoundation`, `libswiftObjectiveC`, `libswiftDispatch`, ...). The copies of those in this repository come from Swift 5.2.2 and are x86_64-only, except `libswiftDarwin`, `libswiftObjectiveC`, `libswiftCoreFoundation`, `libswiftDispatch`, `libswiftos` and `libswiftXPC`. Those six also have arm64 slices, built from the sources in `overlays/` (see `overlays/README.md`).

## License and provenance

- **Runtime libraries:** unmodified binaries from `usr/lib/swift/macosx` in `swift-6.3.3-RELEASE-osx.pkg` from download.swift.org (SHA-256 `ee82e57774d6650f94aa06302435d6f44a055b9411698db8ecb85d9a3bcc91d0`). `libswiftCompatibilitySpan.dylib` is a symlink to `libswiftCore.dylib`, as in the pkg.
- **x86_64 overlay slices:** unmodified binaries from the Swift 5.2.2 macOS pkg.
- **arm64 overlay slices:** built from `overlays/`.
- **`swift_compat.S`:** written for Darling, not taken from a Swift release. `CMakeLists.txt` builds it into `libswiftCoreCompat.dylib`.
- **`libswiftUniformTypeIdentifiers.dylib`:** arm64 only, built from `overlays/UniformTypeIdentifiers/` (written for Darling).

Swift is Copyright Apple Inc. and the Swift project authors, and is licensed under the Apache License v2.0 with Runtime Library Exception. `LICENSE.txt` is the copy shipped in the pkg (`usr/share/swift/LICENSE.txt`). The parts of `overlays/` written for Darling are listed in `overlays/README.md`.

`Combine.framework` is not from a Swift release. Apple's Combine is pure Swift and closed source, so the binary here is [OpenCombine](https://github.com/OpenCombine/OpenCombine) (MIT) built as module `Combine` from `overlays/Combine/`, which is what makes the mangled names of the API it implements match the ones apps import. Coverage is partial and it is arm64 only; see `overlays/README.md`.

`CryptoKit.framework` is not from a Swift release. Apple's CryptoKit is pure Swift and closed source, so the binary here is [swift-crypto](https://github.com/apple/swift-crypto) (Apache-2.0) built as module `CryptoKit` from a pinned commit of [a fork](https://github.com/cristim/swift-crypto/tree/darling/cryptokit-module), which is what makes the mangled names of the API it implements match the ones apps import. Coverage is SHA-256 and HMAC-SHA-256 only and it is arm64 only; see `overlays/README.md`.
