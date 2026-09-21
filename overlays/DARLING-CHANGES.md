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
`Foundation/Locale+Components.swift` and `Foundation/Locale+Language.swift` come from
[apple/swift-foundation](https://github.com/apple/swift-foundation)
(`swift-6.3-DEVELOPMENT-SNAPSHOT-2026-06-07-a`, commit `dbacc67`), from
`Sources/FoundationEssentials/Locale/`. They are vendored rather than fetched because they are
**adapted**: the list below is every way the copies differ from upstream. Apache License v2.0 with
the Runtime Library Exception; upstream file headers are preserved, and swift-foundation's
`LICENSE.md` and `NOTICE.txt` sit alongside them as `Foundation/LICENSE-swift-foundation.md` and
`Foundation/NOTICE-swift-foundation.txt`.
`_FoundationICU` is **not** pulled in. `Locale.Language`, `Locale.LanguageCode`, `Locale.Region` and
`Locale.Currency` all live in `FoundationEssentials`, which does not link ICU: they are value
wrappers over a string identifier plus static ISO code tables. Only the accessors that *reach* them
from a `Locale` live in `FoundationInternationalization`, and those are reimplemented over Darling's
`NSLocale` instead (below).

`CoreGraphics/CGGeometry.swift` comes from
[swift-corelibs-foundation](https://github.com/swiftlang/swift-corelibs-foundation) (`release/5.4`,
`Sources/Foundation/NSGeometry.swift`). It is vendored rather than fetched because only five
extension blocks of that one file are wanted, not the file or the package: the rest defines
`CGPoint`, `CGSize` and `CGRect` as Swift structs, which Darling imports from C instead, and pulls
in `NSSpecialValueCoding`, `NSEdgeInsets` and the `NS*` geometry functions. The five blocks taken
are byte-identical to upstream; the only additions are the file header and the
`import _DarlingCoreGraphicsShims` line that brings the C structs into scope.
Apache License v2.0 with the Runtime Library Exception; the upstream file header is preserved.

Taken: the `CGPoint` and `CGSize` extensions (`zero`, the `Int` and `Double` initializers) with
their `Equatable` conformances, and the `CGRect` extensions (`zero`, the three initializers, `null`,
`infinite`, `width`, `height`, `minX`, `midX`, `maxX`, `minY`, `midY`, `maxY`, `isEmpty`,
`isInfinite`, `isNull`, `contains(_:)` for a point and for a rect, `standardized`, `integral`,
`insetBy(dx:dy:)`, `union(_:)`, `intersection(_:)`, `intersects(_:)`, `offsetBy(dx:dy:)`,
`divided(atDistance:from:)`) with its `Equatable` conformance.

`CoreGraphics/CGGeometry.swift` also carries the `CGSize: Codable` block from the same upstream
file, byte-identical.

`CoreGraphics/CGAffineTransform.swift` carries three blocks from
[swiftlang/swift](https://github.com/swiftlang/swift) (`release/5.4`,
`stdlib/public/Darwin/CoreGraphics/CoreGraphics.swift`): the `Equatable` conformance,
`CGAffineTransform.identity` and the `Codable` conformance. `CoreGraphics.swift`'s `CGColor.components`
body comes from the same upstream file. Apache License v2.0 with the Runtime
Library Exception; the upstream file header is preserved. Upstream's `==` calls `__equalTo`, which
is the name the macOS SDK's `CoreGraphics.apinotes` gives `CGAffineTransformEqualToTransform`;
Darling ships no apinotes, so the C function is called under its own name. That one-word change is
the only departure.

The rest of `CGAffineTransform.swift`, and everything appended to `CoreGraphics.swift`, has no Swift
source upstream: on macOS those members reach Swift as Clang-importer renames driven by
`CoreGraphics.apinotes` (`CGAffineTransformInvert` becomes `CGAffineTransform.inverted()`,
`CGImageGetColorSpace` becomes `getter:CGImage.colorSpace(self:)`, `kCGColorSpaceSRGB` becomes
`CGColorSpace.sRGB`). They are written here over the C functions and constants that Darling's own
headers declare, the same way `CGImage.width` and `CGRect.applying(_:)` already were.

## CoreGraphics members that cannot live in this overlay

Four renames Apple's apinotes supply are **initializers on CF types**, and Swift rejects those in an
extension ("designated initializer cannot be declared in an extension", "convenience initializers
are not supported in extensions of CF types"). They need a `CoreGraphics.apinotes` in Darling's SDK,
or `CF_SWIFT_NAME` on the C declarations, not overlay code:

- `CGColorSpace.init?(name:)` (`CGColorSpaceCreateWithName`)
- `CGColor.init?(colorSpace:components:)` (`CGColorCreate`)
- `CGPath.init(rect:transform:)` (`CGPathCreateWithRect`)
- `CGMutablePath.init()` (`CGPathCreateMutable`)

Three more are absent from Darling's C CoreGraphics altogether, so there is nothing for an overlay
member to call: `CGColorCreateCopyByMatchingToColorSpace` (which backs
`CGColor.converted(to:intent:options:)`), `CGColorSpaceIsHLGBased` and `CGColorSpaceUsesITUR_2100TF`.

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

- **`CGGeometry.swift` follows Apple's semantics where Darling's C CoreGraphics does not.** The
  vendored code is unmodified, so where cocotron's `CGGeometry.m` disagrees with it, the Swift and
  the C answer differ. Three measured cases, all of them cocotron departing from Apple rather than
  the overlay departing from C:
  - `CGRect.infinite` is Apple's `{-CGFloat.greatestFiniteMagnitude / 2, ..., .greatestFiniteMagnitude, ...}`.
    Darling's C global `CGRectInfinite` is `{{0, 0}, {INFINITY, INFINITY}}`, and its own header
    comment asks whether that matches Apple. It does not.
  - `CGRect.intersection(_:)` returns `.null` for disjoint rectangles, as documented. C
    `CGRectIntersection` returns `CGRectZero`.
  - `CGRect.isInfinite` is true only for the infinite rectangle. C `CGRectIsInfinite` is true for any
    rectangle with an infinite field.
  `CGRectNull` agrees in both, which is the one that matters for the null sentinel. Fixing the three
  belongs in cocotron's `CGGeometry.m`, not here.

- **`applying(_:)` and `CGImage.width`/`.height` are written for Darling, in
  `CoreGraphics/CoreGraphics.swift`.** No open-source Swift implementation of them exists: on macOS
  they are Clang-importer renames of `CGRectApplyAffineTransform`, `CGPointApplyAffineTransform`,
  `CGSizeApplyAffineTransform`, `CGImageGetWidth` and `CGImageGetHeight` driven by
  `CoreGraphics.apinotes`, and swift-corelibs-foundation has no `CGAffineTransform` or `CGImage` to
  extend. They call those same C functions, the way the `CGContext` methods beside them do. The two
  `Apply` ones Darling declares as `static inline` behind a macro, so the overlay calls
  `__CGPointApplyAffineTransform` and `__CGSizeApplyAffineTransform` by their real names.

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

`build.sh` is deterministic in its inputs (the swift-collections pin is by commit, and source lists
are sorted with `LC_ALL=C`), but its output is not byte-for-byte reproducible, because `swiftc`
6.3.3 is not. Measured by compiling the untouched `overlays/ObjectiveC/ObjectiveC.swift` twice in
the same directory with identical flags: the two objects differ by 16 bytes, the whole of the
`__swift_modhash` section. Two builds of this branch's `libswiftFoundation.dylib` differ by 26 of
4,110,348 bytes in the arm64 slice: the 16-byte `LC_UUID`, which ld64 derives from the content, and
five 2-byte immediates in `__text`. This predates the AttributedString work and is unrelated to
whether a dependency is vendored or fetched.

## Upstreamable

Nothing so far. No upstream bug was found while vendoring these files.
- **`Locale.Components` is excluded from the build.** In
  `Foundation/Locale+Components.swift` it is kept verbatim but wrapped in `#if
  DARLING_LOCALE_COMPONENTS`, which nothing defines. Two things block it, both in Darling's
  `Calendar` and `TimeZone` rather than in the type itself: its `icuIdentifier` property calls
  `Calendar.Identifier.cldrIdentifier`, `Calendar.Identifier.legacyKeywordKey` and
  `TimeZone.legacyKeywordKey`, and its synthesised `Codable` conformance needs a `Codable`
  `Calendar.Identifier`. This overlay's `Calendar` and `TimeZone` come from the Swift 5.4 Darwin
  overlay, not from swift-foundation, and have none of those. `icuIdentifier` is the whole point of
  the type (it is how a `Locale.Components` turns back into a locale identifier), so a copy without
  it would be a public type that cannot do the one job it exists for. Excluding it costs nothing
  against measured demand: no binary in the macOS 26 app corpus binds a `Locale.Components` symbol.
  Everything else in the file, including `Locale.Script`, `Locale.Collation`,
  `Locale.NumberingSystem`, `Locale.Weekday`, `Locale.HourCycle`, `Locale.MeasurementSystem`,
  `Locale.Subdivision`, `Locale.Variant`, `ICULegacyKey` and the ISO language, region and script
  tables, is compiled unmodified.
- **`Foundation/Locale+Darling.swift` is a Darling reimplementation, not upstream code.** It
  supplies the four accessors that reach the vendored types from a `Locale`: `Locale.language`,
  `Locale.region`, `Locale.currency` and `Locale.Language.languageCode`. Upstream implements these
  in `FoundationInternationalization/Locale/Locale+Components_ICU.swift` and the `_Locale` protocol,
  reading components straight out of ICU through `uloc_getLanguage`, `uloc_getCountry` and friends.
  This overlay's `Locale` is the Swift 5.4 SDK overlay's wrapper around `NSLocale`, which has no
  such internals, so the components are read from `NSLocale` instead: `languageCode`, `scriptCode`,
  `regionCode` and `currencyCode`, which Darling's CoreFoundation backs with its own ICU-backed
  `CFLocale`. That is the same data upstream reads, reached through Darling's own locale machinery.
  Two behavioural differences follow, and neither invents a value:
  - `Locale.region` reads `NSLocaleCountryCode`, so an `rg` override in the identifier is honoured
    only as far as Darling's `CFLocale` honours it. Upstream distinguishes `Locale.region` from
    `Locale.language.region` on exactly that key.
  - `Locale.Language.languageCode` returns the stored `components.languageCode` with no fallback.
    Upstream falls back to `uloc_getLanguage(components.identifier)` when the stored code is nil.
    Every `Locale.Language` initializer this overlay ships stores the code directly, so there is no
    identifier left to parse and the stored value is the complete answer; nil means the language
    genuinely has no code.
- **`Locale.Language.script` and `Locale.Language.region` are not provided.** They are the other two
  members of the same upstream ICU file. Nothing in the app corpus binds them, and adding them would
  be more Darling reimplementation for no measured demand.
## Fixes worth sending upstream
None. Nothing in these two files needed correcting; the only changes are the exclusion above, which
is a statement about Darling's `Calendar` and `TimeZone`, not about swift-foundation.
