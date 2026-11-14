// AttributeScopes.AppKitAttributes and FontAttribute through the AppKit overlay, under Darling.
// Build with -import-objc-header tests/appkit_attributes.h.
import AppKit
import _DarlingAppKitShims

var failures = 0
func check(_ condition: Bool, _ label: String) {
    print(condition ? "ok:" : "FAIL:", label)
    if !condition { failures += 1 }
}

typealias Font = AttributeScopes.AppKitAttributes.FontAttribute

typealias Para = AttributeScopes.AppKitAttributes.ParagraphStyleAttribute

check(Font.name == "NSFont", "FontAttribute.name")
check(Para.name == "NSParagraphStyle", "ParagraphStyleAttribute.name")
check(Para.Value.self == NSParagraphStyle.self, "ParagraphStyleAttribute.Value is NSParagraphStyle")
check(Font.Value.self == NSFont.self, "FontAttribute.Value is NSFont")
check(Font.self is any AttributedStringKey.Type, "FontAttribute is an AttributedStringKey")
// Observed on a real Mac (probe symbols_b_probe1.txt lines 4, 5, 6, 14): both keys are Decodable and Encodable, not
// ObjectiveCConvertible, and zero-size.
check(Font.self is any DecodableAttributedStringKey.Type && Font.self is any EncodableAttributedStringKey.Type, "FontAttribute is Decodable and Encodable")
check(Para.self is any DecodableAttributedStringKey.Type && Para.self is any EncodableAttributedStringKey.Type, "ParagraphStyleAttribute is Decodable and Encodable")
check(!(Font.self is any ObjectiveCConvertibleAttributedStringKey.Type), "FontAttribute is not ObjectiveCConvertible")
check(MemoryLayout<Font>.size == 0 && MemoryLayout<Para>.size == 0, "the keys are zero-size")
check(AttributeScopes.AppKitAttributes.self is any AttributeScope.Type, "AppKitAttributes is an AttributeScope")

let regular = NSFont.systemFont(ofSize: 12)
let bold = NSFont.boldSystemFont(ofSize: 12)

// Dynamic member lookup through AttributeDynamicLookup, and subscript by key type.
var text = AttributedString("hello")
text.font = regular
check(text.font === regular, "AttributedString.font round trip")
check(text[Font.self] === regular, "subscript by FontAttribute.self")
check(text.runs.first?.font === regular, "run.font")
text.font = bold
check(text.font === bold, "font replaced")
text.font = nil
check(text.font == nil, "font removed")

let style = NSParagraphStyle()
var styled = AttributedString("para")
styled.paragraphStyle = style
check(styled.paragraphStyle === style, "AttributedString.paragraphStyle round trip")
check(styled[Para.self] === style && styled.font == nil, "paragraph style leaves the font unset")

var container = AttributeContainer()
container.font = regular
check(container.font === regular, "AttributeContainer.font")
check(container[Font.self] === regular, "AttributeContainer subscript")

// The scope reaches into Foundation's attributes and carries the font through an NSAttributedString dictionary.
let link = NSURL(string: "https://example.com/a")!
let dict: [NSAttributedString.Key: Any] = [NSAttributedString.Key("NSFont"): regular, NSAttributedString.Key("NSLink"): link, NSAttributedString.Key("NSParagraphStyle"): style]
do {
    let scoped = try AttributeContainer(dict, including: \.appKit)
    check(scoped.font === regular, "scoped container converts NSFont")
    check(scoped.paragraphStyle === style, "scoped container converts NSParagraphStyle")
    check(scoped.link == (link as URL), "scoped container converts the Foundation member (link)")
    let back = try [NSAttributedString.Key: Any](scoped, including: \.appKit)
    check(back[NSAttributedString.Key("NSFont")] as? NSFont === regular, "font converts back to the dictionary")
} catch {
    check(false, "scoped initializer threw \(error)")
}

// The default table (used by the unscoped initializers) finds AppKitAttributes through AppKit.framework.
// This needs an AppKit.framework that re-exports libswiftAppKit, as Darling's installed one does.
let unscoped = AttributeContainer(dict)
check(unscoped.font === regular && unscoped.paragraphStyle === style, "default table converts NSFont and NSParagraphStyle")

// The keys' own encode and decode (Darling's Foundation has no AttributedString: Codable), through a property list and a
// JSON round trip. Observed on a real Mac (probe symbols_b_probe2.txt lines 19-35 and 52-55): the value is an
// NSKeyedArchiver archive (secure coding is inferred, not observed), written as Data by a property list encoder and as its base64 string by JSON; the archive is
// version 100000 with the single top-level key "root", and an NSFont archive lists the classes NSFont and NSObject.
struct FontBox: Codable {
    let font: NSFont
    init(_ font: NSFont) { self.font = font }
    func encode(to encoder: Encoder) throws { try Font.encode(font, to: encoder) }
    init(from decoder: Decoder) throws { font = try Font.decode(from: decoder) }
}
struct StyleBox: Codable {
    let style: NSParagraphStyle
    init(_ style: NSParagraphStyle) { self.style = style }
    func encode(to encoder: Encoder) throws { try Para.encode(style, to: encoder) }
    init(from decoder: Decoder) throws { style = try Para.decode(from: decoder) }
}

struct ArchiveShape {
    var archiver: String?
    var version: Int?
    var top: [String]
    var classes: Set<String>
}

func archiveShape(_ data: Data) -> ArchiveShape? {
    guard let plist = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any] else { return nil }
    var classes = Set<String>()
    for object in plist["$objects"] as? [Any] ?? [] {
        if let entry = object as? [String: Any], let names = entry["$classes"] as? [String] { classes.formUnion(names) }
    }
    let archiver = plist["$archiver"] as? String
    let version = plist["$version"] as? Int
    let topDictionary = plist["$top"] as? [String: Any]
    let top: [String] = topDictionary.map { Array($0.keys).sorted() } ?? []
    return ArchiveShape(archiver: archiver, version: version, top: top, classes: classes)
}

do {
    let encoder = PropertyListEncoder()
    encoder.outputFormat = .binary
    let encoded = try encoder.encode([FontBox(bold)])
    let list = try PropertyListSerialization.propertyList(from: encoded, options: [], format: nil) as? [Any]
    let archive = list?.first as? Data
    let shape = archive.flatMap(archiveShape)
    check(archive != nil, "a property list encoder writes the font as Data")
    check(shape?.archiver == "NSKeyedArchiver" && shape?.version == 100000 && shape?.top == ["root"],
          "the archive is an NSKeyedArchiver archive, version 100000, top key root (\(String(describing: shape)))")
    check(shape?.classes == ["NSFont", "NSObject"], "the archive lists exactly NSFont and NSObject (\(shape?.classes.sorted() ?? []))")
    let fonts = try PropertyListDecoder().decode([FontBox].self, from: encoded)
    check(fonts.count == 1 && fonts[0].font.fontName == bold.fontName && fonts[0].font.pointSize == bold.pointSize,
          "FontAttribute decodes the property list back to an NSFont")
} catch {
    check(false, "FontAttribute property list round trip threw \(error)")
}
do {
    let json = try JSONEncoder().encode([FontBox(bold)])
    let strings = try JSONSerialization.jsonObject(with: json) as? [String]
    let archive = strings?.first.flatMap { Data(base64Encoded: $0) }
    check(strings?.count == 1 && archive != nil && archiveShape(archive!)?.top == ["root"], "JSON writes the same archive as a base64 string")
    let fonts = try JSONDecoder().decode([FontBox].self, from: json)
    check(fonts.count == 1 && fonts[0].font.fontName == bold.fontName && fonts[0].font.pointSize == bold.pointSize,
          "FontAttribute decodes the JSON back to an NSFont")
} catch {
    check(false, "FontAttribute JSON round trip threw \(error)")
}

// Known gap: Darling's NSParagraphStyle does not support secure coding, so archiving one throws, where a Mac archives
// it (classes NSMutableParagraphStyle, NSObject and NSParagraphStyle for a mutable style; probe symbols_b_probe2.txt
// line 29). The conformance is declared and fails loudly instead of dropping the style.
do {
    _ = try JSONEncoder().encode([StyleBox(style)])
    check(false, "archiving an NSParagraphStyle is expected to throw in this AppKit (known gap); if it works now, pin the Mac's archive shape")
} catch {
    check(true, "archiving an NSParagraphStyle throws (known gap), it is not dropped silently")
}

print(failures == 0 ? "ALL PASS" : "\(failures) FAILED")
exit(failures == 0 ? 0 : 1)
