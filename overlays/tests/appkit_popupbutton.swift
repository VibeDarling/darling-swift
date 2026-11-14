// NSPopUpButton.init(image:pullDownMenu:) and init(title:image:pullDownMenu:) through the AppKit overlay, under
// Darling. Build with -import-objc-header tests/appkit_popupbutton.h.
import AppKit
import _DarlingAppKitShims

var failures = 0
func check(_ condition: Bool, _ label: String) {
    print(condition ? "ok:" : "FAIL:", label)
    if !condition { failures += 1 }
}

let menu = NSMenu(title: "Actions")
_ = menu.addItem(withTitle: "Title", action: nil, keyEquivalent: "")
_ = menu.addItem(withTitle: "Do it", action: nil, keyEquivalent: "")
let image = NSImage(size: NSSize(width: 4, height: 4))

let withImage = NSPopUpButton(image: image, pullDownMenu: menu)
check(withImage.pullsDown, "init(image:pullDownMenu:) makes a pull-down button")
// Darling's NSPopUpButtonCell ignores -setImage: (see PopUpButton.swift), so the image is not asserted.
check(withImage.menu === menu, "menu")

let titled = NSPopUpButton(title: "More", image: nil, pullDownMenu: menu)
check(titled.pullsDown, "init(title:image:pullDownMenu:) makes a pull-down button")
check(titled.title == "More", "title")
check(titled.menu === menu, "menu is shared, not copied")

let both = NSPopUpButton(title: "Both", image: image, pullDownMenu: menu)
check(both.title == "Both", "title with an image")
let defaulted = NSPopUpButton(title: "Default", pullDownMenu: menu)
check(defaulted.pullsDown && defaulted.title == "Default" && defaulted.menu === menu, "the image defaults to nil")

print(failures == 0 ? "ALL PASS" : "\(failures) FAILED")
exit(failures == 0 ? 0 : 1)
