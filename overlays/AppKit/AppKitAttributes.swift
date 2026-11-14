// AttributeScopes.AppKitAttributes with its font and paragraph style attributes, for AttributedString.
//
// Provenance. Apple's public documentation (developer.apple.com/documentation/foundation/attributescopes/appkitattributes
// and .../fontattribute) gives: AppKitAttributes is a struct conforming to AttributeScope with instance properties such
// as `font`, `paragraphStyle` and `foundation`; FontAttribute is a @frozen enum conforming to AttributedStringKey,
// DecodableAttributedStringKey and EncodableAttributedStringKey. The values below were observed on a real Mac
// (macOS 26.1, Swift 6.2.4; probe symbols_b_probe1.swift, output symbols_b_probe1.txt lines 1-14): FontAttribute.name
// and NSAttributedString.Key.font.rawValue are "NSFont" and Value is NSFont; ParagraphStyleAttribute.name and
// NSAttributedString.Key.paragraphStyle.rawValue are "NSParagraphStyle" and Value is NSParagraphStyle; both keys are
// Decodable and Encodable, neither is ObjectiveCConvertible, and both are zero-size enums.
//
// Foundation finds this scope by looking up its type metadata symbol in AppKit (see _loadDefaultAttributes), so the
// mangled names below are the ones macOS apps and Foundation bind to.
//
// Encoding, observed on a real Mac (probe symbols_b_probe2.txt, macOS 26.1): an AttributedString encodes as a flat array
// of text and attribute dictionaries keyed "NSFont" and "NSParagraphStyle"; the values are secure NSKeyedArchiver
// archives (version 100000, the one top-level key "root"), written as Data by a property list encoder and as their base64
// string by JSON (lines 1-35); a single NSFont through the key's own encode is one such string (lines 52-55). An NSFont
// archive lists the classes NSFont and NSObject; an NSMutableParagraphStyle archive lists NSMutableParagraphStyle,
// NSObject and NSParagraphStyle. The keys below do the same with NSKeyedArchiver. Darling's NSFont archive has the
// same shape (tests/appkit_attributes.swift pins it). Darling's Foundation has no AttributedString: Codable (it is
// FOUNDATION_FRAMEWORK-only upstream), so only the keys' encode and decode are reachable here.
//
// What differs: Darling's NSParagraphStyle does not support secure coding, so ParagraphStyleAttribute.encode throws
// where a Mac archives the style; the conformance is declared anyway so that an archive made on a Mac reaches
// decode, and the failure is loud. Not observed: whether decoding a Mac's NSFont archive works with Darling's NSFont.
//
// The other documented attribute members of the scope (foregroundColor, kern, ...) and `accessibility` are not
// defined: no analysed app has demanded them yet.

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
    public enum FontAttribute : EncodableAttributedStringKey, DecodableAttributedStringKey {
        public typealias Value = NSFont

        public static var name: String { "NSFont" }

        public static func encode(_ value: NSFont, to encoder: Encoder) throws {
            try encodeArchived(value, to: encoder)
        }

        public static func decode(from decoder: Decoder) throws -> NSFont {
            return try decodeArchived(NSFont.self, from: decoder)
        }
    }
}

@available(macOS 12, *)
extension AttributeScopes.AppKitAttributes {
    @frozen
    public enum ParagraphStyleAttribute : EncodableAttributedStringKey, DecodableAttributedStringKey {
        public typealias Value = NSParagraphStyle

        public static var name: String { "NSParagraphStyle" }

        public static func encode(_ value: NSParagraphStyle, to encoder: Encoder) throws {
            try encodeArchived(value, to: encoder)
        }

        public static func decode(from decoder: Decoder) throws -> NSParagraphStyle {
            return try decodeArchived(NSParagraphStyle.self, from: decoder)
        }
    }
}

@available(macOS 12, *)
extension AttributeScopes.AppKitAttributes.FontAttribute : Sendable {}

@available(macOS 12, *)
extension AttributeScopes.AppKitAttributes.ParagraphStyleAttribute : Sendable {}

private func encodeArchived(_ value: NSObject, to encoder: Encoder) throws {
    let data = try NSKeyedArchiver.archivedData(withRootObject: value, requiringSecureCoding: true)
    var container = encoder.singleValueContainer()
    try container.encode(data)
}

private func decodeArchived<T: NSObject & NSSecureCoding>(_ type: T.Type, from decoder: Decoder) throws -> T {
    let container = try decoder.singleValueContainer()
    let data = try container.decode(Data.self)
    guard let result = try NSKeyedUnarchiver.unarchivedObject(ofClass: type, from: data) else {
        throw DecodingError.dataCorrupted(.init(codingPath: decoder.codingPath, debugDescription: "Unable to unarchive object, result was nil"))
    }
    return result
}
