// AttributeScopes.AppKitAttributes with its font and paragraph style attributes, for AttributedString.
//
// Written from Apple's public documentation (developer.apple.com/documentation/foundation/attributescopes/appkitattributes
// and .../fontattribute), which gives this: AppKitAttributes is a struct conforming to AttributeScope; FontAttribute is a
// @frozen enum conforming to AttributedStringKey, DecodableAttributedStringKey and EncodableAttributedStringKey; the
// scope has instance properties such as `font: AttributeScopes.AppKitAttributes.FontAttribute`, `paragraphStyle` and
// `foundation`.
// The Foundation overlay finds this scope by looking up its type metadata symbol in AppKit (see _loadDefaultAttributes),
// so the mangled names below are the ones macOS apps and Foundation bind to.
//
// GUESS / NEEDS-REAL-MAC, not in the public documentation:
//  - FontAttribute.Value is NSFont and ParagraphStyleAttribute.Value is NSParagraphStyle (the types the matching
//    NSAttributedString keys carry);
//  - FontAttribute.name is "NSFont" and ParagraphStyleAttribute.name is "NSParagraphStyle" (the raw values of
//    NSAttributedString.Key.font and .paragraphStyle, as FoundationAttributes.LinkAttribute hard-codes "NSLink");
//  - the Decodable/EncodableAttributedStringKey conformances are left out (they need a secure-coding encoding of the
//    value whose format the documentation does not give).
// The other documented attribute members of the scope (foregroundColor, kern, ...) and `accessibility` are not defined:
// no analysed app has demanded them yet.

@_exported import Foundation
#if DARLING_APPKIT_CLANG_MODULE
import AppKit
#else
import _DarlingAppKitShims
#endif

@available(macOS 12, *)
extension AttributeScopes {
    public var appKit: AppKitAttributes.Type { AppKitAttributes.self }

    public struct AppKitAttributes : AttributeScope {
        public let font: FontAttribute
        public let paragraphStyle: ParagraphStyleAttribute
        public let foundation: AttributeScopes.FoundationAttributes
    }
}

@available(macOS 12, *)
extension AttributeDynamicLookup {
    public subscript<T: AttributedStringKey>(dynamicMember keyPath: KeyPath<AttributeScopes.AppKitAttributes, T>) -> T {
        return self[T.self]
    }
}

@available(macOS 12, *)
extension AttributeScopes.AppKitAttributes {
    @frozen
    public enum FontAttribute : AttributedStringKey {
        public typealias Value = NSFont

        public static var name: String { "NSFont" }
    }
}

@available(macOS 12, *)
extension AttributeScopes.AppKitAttributes {
    @frozen
    public enum ParagraphStyleAttribute : AttributedStringKey {
        public typealias Value = NSParagraphStyle

        public static var name: String { "NSParagraphStyle" }
    }
}

@available(macOS 12, *)
extension AttributeScopes.AppKitAttributes.FontAttribute : Sendable {}

@available(macOS 12, *)
extension AttributeScopes.AppKitAttributes.ParagraphStyleAttribute : Sendable {}
