// NSPopUpButton.init(image:pullDownMenu:) and init(title:image:pullDownMenu:).
//
// Provenance. Names: Mail imports them. Declarations and behaviour: Apple's public documentation
// (developer.apple.com/documentation/appkit/nspopupbutton/init(title:image:pulldownmenu:) and
// .../init(image:pulldownmenu:)): each "creates a standard pull-down button with a title, optional image, and
// menu"; `title` is the title and `image` the icon displayed on the button, `pullDownMenu` the menu it presents;
// the button's `usesItemFromMenu` is false. The documentation does not say whether the first form leaves the
// title empty; this leaves it unchanged.
//
// Known gap: `usesItemFromMenu` is not set, because Darling's NSPopUpButtonCell has no such property, and
// its -setImage: has no effect (it takes a pull-down button's image from the menu's first item), so the image
// is stored but not displayed until Darling's AppKit supports an image on the button itself.

@_exported import Foundation
#if DARLING_APPKIT_CLANG_MODULE
@_exported import AppKit
#else
import _DarlingAppKitShims
#endif

extension NSPopUpButton {
    /// A pull-down button that shows `image` and pulls down `menu`.
    public convenience init(image: NSImage, pullDownMenu: NSMenu) {
        self.init(frame: .zero, pullsDown: true)
        self.menu = pullDownMenu
        self.image = image
    }

    /// A pull-down button that shows `title` and `image` and pulls down `menu`.
    public convenience init(title: String, image: NSImage? = nil, pullDownMenu: NSMenu) {
        self.init(frame: .zero, pullsDown: true)
        self.menu = pullDownMenu
        self.title = title
        self.image = image
    }
}
