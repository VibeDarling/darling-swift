# Darling changes to vendored upstream sources

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

## Darling-specific adaptations

These exist because of something Darling's SDK does or does not provide. They should not be sent
upstream.

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

## Fixes worth sending upstream

None. Nothing in these two files needed correcting; the only changes are the exclusion above, which
is a statement about Darling's `Calendar` and `TimeZone`, not about swift-foundation.
