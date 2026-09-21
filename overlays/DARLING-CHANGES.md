# Darling changes to vendored upstream sources

Sources under `Foundation/` come from [apple/swift-foundation](https://github.com/apple/swift-foundation)
(`swift-6.3-DEVELOPMENT-SNAPSHOT-2026-06-07-a`, commit `dbacc67`) and from the Swift 5.4 Darwin
overlay. They are vendored because they are **adapted**: the list below is what had to change for
them to build against Darling's SDK. Apache License v2.0 with the Runtime Library Exception;
upstream file headers are preserved, and swift-foundation's `LICENSE.md` and `NOTICE.txt` sit
alongside them.

[apple/swift-collections](https://github.com/apple/swift-collections) is **not** vendored. It is
consumed exactly as upstream ships it, so `build.sh` fetches it at a pinned commit
(`c11818f3cae0780656baa430b49e7f163f08dffd`, which is what tag `1.1.6` points at) and compiles it
in place. Nothing about it is adapted, so there is nothing for this file to record and no reason
for 94 unmodified files to live in the repository. Its `LICENSE.txt` comes with the checkout.
Set `SWIFT_COLLECTIONS_SRC` to an existing checkout of that commit to build offline.

This file records every way the vendored copies differ from upstream, split into changes that only
make sense for Darling and changes that would be worth sending upstream.

## Darling-specific adaptations

These exist because of something Darling's SDK does or does not provide. They should not be sent
upstream.

- **`Foundation/CodableUtilities.swift` reduced to two declarations.** Only `EmptyCodingKeys` and
  `DefaultAssociatedValueCodingKeys1` are kept, which is all that `AttributedString`'s
  `CodableWithConfiguration` conformances reference. The rest of the upstream file is JSON decoding
  support built on `BufferView`, which would pull in the whole `FoundationEssentials/JSON`
  directory.

- **`Foundation/String+Comparison.swift` reduced to the two UTF-8 code-unit constants.**
  `StringBlocks.swift` needs `UTF8.CodeUnit.newline` and `.carriageReturn`. The rest of the upstream
  file is the pure-Swift string comparison implementation, which needs the Unicode scalar property
  tables (`UnicodeScalar.swift`, `BuiltInUnicodeScalarSet.swift`) that this overlay does not vendor.

- **`Foundation/AttributedStringProtocol.swift`: `range(of:options:locale:)` and its `_range`
  helper omitted.** Both declare a `String.CompareOptions = []` default argument. Darling's
  `NSStringCompareOptions` imports as a plain raw-value struct rather than a Swift `OptionSet` (the
  same limitation `NSStringAPI.swift` already works around with
  `NSStringCompareOptions(rawValue:)`), so the array literal does not type-check. The body also
  needs `Substring._range(of:options:)` from the reduced `String+Comparison.swift`. No binary in the
  macOS 26 app corpus binds either symbol, so nothing is lost against measured demand. Fixing
  Darling's `NSString.h` import would let both come back unmodified.

- **swift-collections built without library evolution and linked into `libswiftFoundation`.**
  `InternalCollectionsUtilities` and `_RopeModule` are an implementation detail of
  `AttributedString`'s storage, not part of the SDK, so `build.sh` compiles them to objects and
  links those into the Foundation dylib rather than shipping them as dylibs. Apple links
  `CollectionsInternal` into `Foundation.framework` the same way, and hides its symbols, so
  `build.sh` passes ld64 an `-unexported_symbols_list` naming both module prefixes to keep their
  1,159 symbols out of the dylib's export table. Their own sources are unmodified; this is a
  choice about how they are built, not a change to them.

- **`build.sh` passes `-package-name swift-foundation`.** Without it, `package`-level declarations
  such as `LockedState` silently degrade to `fileprivate` and the module does not compile. The value
  matches swift-foundation's own package identity so `package` symbols mangle as upstream does.

## Not vendored, and why

Nothing here is stubbed or approximated. These are left out because no honest source exists in the
tree:

- The `#if FOUNDATION_FRAMEWORK`-guarded parts of the vendored files. The files themselves are
  vendored whole and their unguarded declarations do compile, so `AttributeScopes` and
  `FoundationAttributes` exist; what is missing is the guarded half, which is where the attribute
  scope's dynamic registration, `AttributedString`'s `Codable` conformances and
  `AttributedString(NSAttributedString)` live. That mode needs the Clang modules `MachO.dyld`,
  `ReflectionInternal`, `CollectionsInternal` and `Foundation_Private.NSAttributedString`, none of
  which Darling has.
- The ICU-backed `FormatStyle` implementations and `AttributedString(localized:)`. They need
  `_FoundationICU` from swift-foundation-icu.
- `AttributedString(markdown:)` and `MarkdownParsingOptions`, which need swift-cmark.
- `InlinePresentationIntent`. It is not declared anywhere in swift-foundation, and
  `NSInlinePresentationIntent` is absent from darling-foundation's headers, so there is nothing to
  vendor. It is not invented here.

## Reproducibility

`build.sh` is bit-reproducible when run twice from the same directory: wiping `overlays/build` and
rebuilding produces an identical `libswiftFoundation.dylib`.

It is not reproducible across different build directories. Two builds of the same commit at
different paths give an arm64 slice differing by 26 of 4,110,348 bytes: the 16-byte `LC_UUID`,
which ld64 derives from the content, and five `mov w2, #imm` immediates in `__text` whose values
track the build root's path length exactly (a 41-character root gives 76, an 81-character root 116,
an 83-character root 118). `__swift_modhash` never reaches the dylib; the linker drops it.

This predates the AttributedString work and is not related to whether a dependency is vendored or
fetched. Measured on the tree of #33, which is master plus a CryptoKit framework and contains none
of this branch's changes: built at two different paths, `libswiftFoundation.dylib` differs by 21
bytes and `libswiftDispatch.dylib` by 27, while `Darwin`, `ObjectiveC`, `CoreFoundation`, `os`,
`XPC`, `CoreGraphics`, `AppKit` and `CryptoKit` are all bit-identical.

## Upstreamable

Nothing so far. No upstream bug was found while vendoring these files.
