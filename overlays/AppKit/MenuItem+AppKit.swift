// NSMenuItem.sectionHeader(title:) (macOS 14): a non-interactive item that titles the items after it.
//
// Provenance. Name: Reminders imports it (rung 5, llvm-nm -u -m). Declaration and behaviour: Apple's public
// documentation, https://developer.apple.com/documentation/appkit/nsmenuitem/sectionheader(title:) (`static func
// sectionHeader(title: String) -> NSMenuItem`; "items created using this method are non-interactive and don't
// perform actions"). Apple's SDK imports the Objective-C `+sectionHeaderWithTitle:` under this Swift name; Darling's
// header carries no Swift name, so this forwards to Darling AppKit's own `+sectionHeaderWithTitle:`.
// Nothing here is a GUESS apart from the Objective-C side: the item's non-interactive behaviour is Darling AppKit's.

@_exported import Foundation
#if DARLING_APPKIT_CLANG_MODULE
@_exported import AppKit
#else
import _DarlingAppKitShims
#endif

extension NSMenuItem {
    /// A non-interactive item that gives context to the group of items after it.
    public static func sectionHeader(title: String) -> NSMenuItem {
        return NSMenuItem.sectionHeader(withTitle: title)
    }
}
