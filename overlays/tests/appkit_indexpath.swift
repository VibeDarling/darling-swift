// IndexPath(item:section:), item and section, and the numeric raw-representable operators of NSLayoutConstraint.Priority
// and NSToolbarItem.VisibilityPriority, from the AppKit overlay, under Darling.
import AppKit
import _DarlingAppKitShims

var failures = 0
func check(_ condition: Bool, _ label: String) {
    print(condition ? "ok:" : "FAIL:", label)
    if !condition { failures += 1 }
}

var path = IndexPath(item: 3, section: 1)
check(path.section == 1 && path.item == 3, "init stores [section, item]")
check(path == IndexPath(indexes: [1, 3]), "equal to the two-element path")
path.item = 5
path.section = 2
check(path == IndexPath(indexes: [2, 5]), "item and section are settable")
check(IndexPath(item: 0, section: 0) < IndexPath(item: 0, section: 1), "ordered by section first")

check((NSLayoutConstraint.Priority.defaultLow + 10).rawValue == 260, "priority + raw value")
check((NSLayoutConstraint.Priority.required - 1).rawValue == 999, "priority - raw value")
check(NSLayoutConstraint.Priority.required - NSLayoutConstraint.Priority.defaultHigh == 250, "priority - priority is a raw value")
check(NSLayoutConstraint.Priority.defaultLow < NSLayoutConstraint.Priority.defaultHigh, "priorities are comparable")
var priority = NSLayoutConstraint.Priority.defaultLow
priority += 5
check(priority.rawValue == 255, "priority += raw value")
// Relative to the constant, so the test does not depend on the shim's guessed constant values.
let high = NSToolbarItem.VisibilityPriority.high
check((high + 7).rawValue == high.rawValue + 7, "toolbar priority + raw value")
check((high - 1).rawValue == high.rawValue - 1, "toolbar priority - raw value")
check(high - NSToolbarItem.VisibilityPriority.low == high.rawValue - NSToolbarItem.VisibilityPriority.low.rawValue, "toolbar priority - priority")

if failures != 0 { exit(1) }
