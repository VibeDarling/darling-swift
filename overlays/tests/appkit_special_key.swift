// NSEvent.SpecialKey, NSEvent.specialKey and NSColor(_colorLiteralRed:green:blue:alpha:) through the AppKit overlay,
// under Darling. Build with -import-objc-header tests/appkit_special_key.h.
import AppKit
import _DarlingAppKitShims

var failures = 0
func check(_ condition: Bool, _ label: String) {
    print(condition ? "ok:" : "FAIL:", label)
    if !condition { failures += 1 }
}

// The values are the Unicode scalars AppKit documents for these keys (NSEvent.h function-key and control-character
// constants), which the open-source overlay hard-codes.
check(NSEvent.SpecialKey.upArrow.rawValue == 0xF700, "upArrow is U+F700")
check(NSEvent.SpecialKey.home.rawValue == 0xF729, "home is U+F729")
check(NSEvent.SpecialKey.end.rawValue == 0xF72B, "end is U+F72B")
check(NSEvent.SpecialKey.enter.rawValue == 0x0003, "enter is U+0003")
check(NSEvent.SpecialKey.carriageReturn.rawValue == 0x000D, "carriageReturn is U+000D")
check(NSEvent.SpecialKey.home != NSEvent.SpecialKey.end, "SpecialKey is Equatable")
check(Set([NSEvent.SpecialKey.home, .home, .end]).count == 2, "SpecialKey is Hashable")
check(NSEvent.SpecialKey.carriageReturn.unicodeScalar == "\r", "unicodeScalar")

// specialKey reads charactersIgnoringModifiers of a real NSEvent in Darling's AppKit (NSEventTypeKeyDown is 10).
func specialKey(of characters: String) -> NSEvent.SpecialKey? {
    let event = NSEvent.keyEvent(
        withType: 10, location: NSPoint(x: 0, y: 0), modifierFlags: 0, timestamp: 0, windowNumber: 0, context: nil,
        characters: characters, charactersIgnoringModifiers: characters, isARepeat: false, keyCode: 0)
    return event?.specialKey
}
check(specialKey(of: "\r") == .carriageReturn, "specialKey of a return key event")
check(specialKey(of: "\u{F729}") == .home, "specialKey of a home key event")
check(specialKey(of: "\u{F72B}") == .end, "specialKey of an end key event")
check(specialKey(of: "a") == nil, "specialKey of a letter is nil")
check(specialKey(of: "ab") == nil, "specialKey of two characters is nil")

// The initializer `#colorLiteral(red:green:blue:alpha:)` expands to.
let color = NSColor(_colorLiteralRed: 0.25, green: 0.5, blue: 0.75, alpha: 1)
func near(_ a: CGFloat, _ b: CGFloat) -> Bool { return abs(a - b) < 0.001 }
check(near(color.redComponent, 0.25) && near(color.greenComponent, 0.5) && near(color.blueComponent, 0.75)
      && near(color.alphaComponent, 1), "colorLiteral components (\(color.redComponent), \(color.greenComponent), \(color.blueComponent), \(color.alphaComponent))")

print(failures == 0 ? "ALL PASSED" : "\(failures) FAILED")
if failures != 0 { exit(1) }
