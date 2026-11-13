// IndexPath(item:section:) and item from the AppKit overlay, under Darling.
import AppKit
import _DarlingAppKitShims

var failures = 0
func check(_ condition: Bool, _ label: String) {
    print(condition ? "ok:" : "FAIL:", label)
    if !condition { failures += 1 }
}

let path = IndexPath(item: 3, section: 1)
check(path.item == 3, "item is the second index")
check(path == IndexPath(indexes: [1, 3]), "init stores [section, item]")
check(path[0] == 1, "the section is the first index")
check(IndexPath(item: 0, section: 0) < IndexPath(item: 0, section: 1), "ordered by section first")

if failures != 0 { exit(1) }
