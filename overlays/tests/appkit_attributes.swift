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

print(failures == 0 ? "ALL PASS" : "\(failures) FAILED")
exit(failures == 0 ? 0 : 1)
