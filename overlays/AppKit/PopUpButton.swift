// NSPopUpButton.init(image:pullDownMenu:) and init(title:image:pullDownMenu:).
//
// Provenance. Names: Freeform imports the `title:` form and Mail the image-only form. Declarations: Apple's public
// documentation (developer.apple.com/documentation/appkit/nspopupbutton/init(title:image:pulldownmenu:) and
// .../init(image:pulldownmenu:)): each "creates a standard pull-down button with a title, optional image, and menu";
// `title` is the title and `image` the icon displayed on the button, `pullDownMenu` the menu it presents; the
// button's `usesItemFromMenu` is false. Behaviour: observed on a real Mac (macOS 26.1, probe symbols_b_probe1,
// output lines 17-18): both forms give pullsDown true and leave the menu as it was (same object, same two items,
// the first still titled "first"); the image-only form has title "" and keeps the image (`image === img`),
// usesItemFromMenu false and titleOfSelectedItem "first"; the title form with image nil has title "T".
//
// GUESS / NEEDS-REAL-MAC: what the Mac does with an EMPTY menu (probe symbols_b_probe2 asks). Here the button is
// made with the menu as given, the title is stored, and nothing is added to the menu.
//
// Known gaps in Darling's AppKit, not in this file: NSPopUpButtonCell has no `usesItemFromMenu` and its -setImage:
// has no effect (it takes a pull-down button's image from the menu's first item), so the image is stored but not
// displayed, and `usesItemFromMenu` is not set.
//
// The title is set on the button's cell, through key-value coding, because Darling's NSPopUpButton -setTitle: on a
// pull-down button renames the menu's first item (and raises on an empty menu), which the Mac does not do.

@_exported import Foundation
#if DARLING_APPKIT_CLANG_MODULE
@_exported import AppKit
#else
import _DarlingAppKitShims
#endif

extension NSPopUpButton {
    /// A pull-down button that shows `image` and pulls down `menu`; its title is empty.
    public convenience init(image: NSImage, pullDownMenu: NSMenu) {
        self.init(frame: .zero, pullsDown: true)
        self.menu = pullDownMenu
        setCellTitle("")
        self.image = image
    }

    /// A pull-down button that shows `title` and `image` and pulls down `menu`.
    public convenience init(title: String, image: NSImage? = nil, pullDownMenu: NSMenu) {
        self.init(frame: .zero, pullsDown: true)
        self.menu = pullDownMenu
        setCellTitle(title)
        self.image = image
    }

    private func setCellTitle(_ title: String) {
        (value(forKey: "cell") as? NSObject)?.setValue(title, forKey: "title")
    }
}
