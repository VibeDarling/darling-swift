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

// The keys' own encode and decode (Darling's Foundation has no AttributedString: Codable), through a JSON round trip.
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
do {
    let fonts = try JSONDecoder().decode([FontBox].self, from: try JSONEncoder().encode([FontBox(bold)]))
    check(fonts.count == 1 && fonts[0].font.fontName == bold.fontName && fonts[0].font.pointSize == bold.pointSize,
          "FontAttribute encodes and decodes an NSFont")
} catch {
    check(false, "FontAttribute round trip threw \(error)")
}
// Known gap: Darling's NSParagraphStyle does not support secure coding, so archiving one throws (the real one is
// NSSecureCoding). The conformance is declared and fails loudly instead of dropping the style.
do {
    let styles = try JSONDecoder().decode([StyleBox].self, from: try JSONEncoder().encode([StyleBox(style)]))
    check(styles.count == 1 && type(of: styles[0].style) == type(of: style), "ParagraphStyleAttribute encodes and decodes an NSParagraphStyle")
} catch {
    print("info: ParagraphStyleAttribute archiving throws in this AppKit (known gap)")
}

print(failures == 0 ? "ALL PASS" : "\(failures) FAILED")
exit(failures == 0 ? 0 : 1)
