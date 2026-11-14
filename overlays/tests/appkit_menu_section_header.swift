// NSMenuItem.sectionHeader(title:) and the NSApplication HDR notification names from the AppKit overlay, under Darling.
import AppKit
import _DarlingAppKitShims

var failures = 0
func check(_ condition: Bool, _ label: String) {
    print(condition ? "ok:" : "FAIL:", label)
    if !condition { failures += 1 }
}

let header = NSMenuItem.sectionHeader(title: "Recents")
check(header.title == "Recents", "title")
check(!header.isEnabled, "a section header is not interactive")
check(NSMenuItem.sectionHeader(title: "").title == "", "an empty title")

check(NSApplication.ShouldBeginSuppressingHighDynamicRangeContent.name.rawValue == "NSApplicationShouldBeginSuppressingHighDynamicRangeContentNotification", "HDR begin notification name")
check(NSApplication.ShouldEndSuppressingHighDynamicRangeContent.name.rawValue == "NSApplicationShouldEndSuppressingHighDynamicRangeContentNotification", "HDR end notification name")

if failures != 0 { exit(1) }
