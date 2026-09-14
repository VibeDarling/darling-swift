# arm64 Swift SDK overlays

Swift.org toolchains stopped shipping the Darwin SDK overlays, so the copies in this repository were x86_64-only (Swift 5.2.2). `build.sh` builds arm64 slices of seven of them and merges them into the existing universal binaries. The x86_64 slices are unchanged. Four are built from the last open-source Swift sources; `os` and `XPC` were never open source, so they are written from Apple's public API documentation and the imported symbol names (no Apple code).

| Overlay | Sources | Notes |
|---|---|---|
| `libswiftDarwin` | `swiftlang/swift` `release/6.1`, `stdlib/public/Platform` (`Darwin.swift` and `tgmath.swift` pre-expanded with gyb) | Needed at build time by the other overlays: the Clang importer maps C `Boolean` to `Darwin.DarwinBoolean` |
| `libswiftObjectiveC` | `release/5.4`, `stdlib/public/Darwin/ObjectiveC` | Unmodified |
| `libswiftCoreFoundation` | `release/5.4` `CoreFoundation.swift`, plus `CGFloat.swift` from the 5.4 CoreGraphics overlay | Newer SDKs moved `CGFloat` into this overlay; it's declared `@_originallyDefinedIn(module: "CoreGraphics", ...)` so its symbols keep their `CoreGraphics` mangling |
| `libswiftDispatch` | `release/5.4`, `stdlib/public/Darwin/Dispatch` | `Schedulers+DispatchQueue.swift` is dropped (it needs Combine). `Darling+NewerSDK.swift` and a designated `DispatchWorkItem.init(flags:block:)` add APIs from newer SDKs. `DarlingSerialExecutor.m` defines `OS_dispatch_queue_serial_executor` until Darling's libdispatch does |
| `libswiftos` | Clean-room (`os/os.swift`) | `Logger`, `os_log`, `os_signpost`, `OSSignpostID`, `OSSignposter`, `OSSignpostIntervalState`, `OSAllocatedUnfairLock`, and the `OSLog`/`OSLogType`/`OSSignpostType` extensions. `os_log` encodes arguments into the os_log buffer format and calls `_os_log_impl`. Signposts report as disabled: Darling's libsystem_trace signpost entry points abort |
| `libswiftXPC` | Clean-room (`XPC/XPC.swift`) | `XPCSession`, `XPCDictionary` (copy-on-write, with Bool/String/integer/object/dictionary/array subscripts), `XPCArray` and `XPCRichError`, on top of libxpc's C API |
| `libswiftFoundation` | `release/5.4` `stdlib/public/Darwin/Foundation/{String,NSArray,NSDictionary,NSSet}.swift`, reduced | **Intentionally partial:** only the `_ObjectiveCBridgeable` conformances of `String`, `Array`, `Dictionary` and `Set`, `String(_: NSString)`, and the `-[NSObject newTaggedNSStringWithASCIIBytes_:length_:]` hook the runtime uses to bridge small ASCII strings. Non-verbatim `Dictionary` bridging always uses the 5.4 overlay's enumeration path, so it doesn't need the `__NSDictionaryGetObjects` shim. The arm64 slice replaces none of the x86_64 slice's API |

Sources from the Swift project are licensed under the Apache License v2.0 with Runtime Library Exception. `os/`, `XPC/`, `Dispatch/Darling+NewerSDK.swift`, `Dispatch/DarlingSerialExecutor.m`, `Dispatch/include/swift/Runtime/Debug.h` and `tests/` were written for Darling.

### Why Foundation is bridging-only

The full 5.4 Foundation overlay doesn't compile against Darling's Foundation headers, which have no `@property` declarations, nullability or Swift names; that gives about 2,300 errors. It also calls Objective-C APIs Darling lacks. macOS 14+ apps import their Swift Foundation symbols (1,616 of them in macOS 26's apps) from `Foundation.framework` itself, so a fuller overlay would also need Darling's Foundation to re-export it. Bridging `String` and the collection types is the piece Swift code needs first: 25 of the apps import the `Array`/`Dictionary`/`Set` bridging entry points. To be useful from Swift, it relies on `Foundation.apinotes` `SwiftBridge` entries (VibeDarling/darling-foundation#5).

## Coverage of what macOS 26 apps import

Measured against every binary in `/System/Applications` of a macOS 26.6.2 install:

- **ObjectiveC:** 14/14 symbols.
- **CoreFoundation:** 15/15, including the `$s12CoreGraphics7CGFloatV…` metadata and conformances.
- **os:** 44/44.
- **XPC:** 21/21.
- **Dispatch:** 94/104. The missing 10 are the Combine `Scheduler` conformance of `DispatchQueue` and its `SchedulerTimeType`/`SchedulerOptions` types (Combine is closed source).
- **Foundation:** 16 of the 1,288 unique Swift symbols apps bind to `Foundation.framework`: the `String`, `Array`, `Dictionary` and `Set` bridging entry points. That fully covers TextEdit. Apps bind these symbols to `Foundation.framework`, so they only resolve once Darling's Foundation re-exports this dylib (a CMake `-reexport_library`, tested by adding the load command to a copy of Foundation).

## Building

See the header of `build.sh` for the required toolchain, resource directory, and Darling SDK/ld64/libSystem paths. The Darling SDK must include the Clang module maps for Darwin, ObjectiveC, Dispatch, os, XPC, CoreFoundation and Foundation, and the `sys/cdefs.h` default-platform fix. Without that fix, arm64 code links against `$UNIX2003` symbol variants that don't exist. Foundation also needs the CoreServices sub-frameworks (`AE`, `CarbonCore`) reachable as top-level frameworks and the `libDER/DERItem.h` guard.

## Tests

`tests/os_xpc.swift` covers `Logger`, `os_log` with arguments, signpost IDs and intervals, `OSAllocatedUnfairLock` across threads, `XPCDictionary`/`XPCArray` and `XPCSession`. `tests/objc_only.swift` and `tests/objc_cf.swift` cover an NSObject subclass with `@objc` methods and selectors, NSObject `Equatable`/`Hashable`, `autoreleasepool`, `ObjCBool`, CF types as `Hashable` (`_CFObject`), CFString round trips, and CGFloat. `tests/string_bridging.swift` covers `String` ↔ `NSString` conversions, `String` arguments and results of Objective-C methods, `AnyObject` casts and small-string bridging. It passes 8/8 under Darling with darling-foundation#6 installed. Before that fix, `-[NSString uppercaseString]` on a Swift-native string returned garbage. `tests/collection_bridging.swift` covers `Array`, `Dictionary` and `Set` round trips through their NS counterparts: verbatim and non-verbatim element types, collections built in Objective-C, failing conditional casts, and `nil` → empty. It passes 15/15. Build the tests for `arm64-apple-macosx26.0` against these overlays, link with Darling's ld64 (`objc_only`/`objc_cf` also need `-Xfrontend -disable-objc-attr-requires-foundation-module`), and run them with `darling shell`.
