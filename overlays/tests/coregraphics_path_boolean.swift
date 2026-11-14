// CGPathFillRule and the CGPath boolean operations (declared, trapping) through the CoreGraphics overlay.
// Run with no argument for the checks, or with `union`, `intersection` or `subtracting` to call that operation,
// which must trap with a message naming it.
import CoreGraphics

var failures = 0
func check(_ condition: Bool, _ label: String) {
    print(condition ? "ok:" : "FAIL:", label)
    if !condition { failures += 1 }
}

let path = CGMutablePath()!
CGPathAddRect(path, nil, CGRect(x: 0, y: 0, width: 4, height: 4))

if CommandLine.arguments.count > 1 {
    let other: CGPath = path
    switch CommandLine.arguments[1] {
    case "union": _ = path.union(other)
    case "intersection": _ = path.intersection(other, using: .evenOdd)
    case "subtracting": _ = path.subtracting(other)
    default: print("unknown operation")
    }
    print("FAIL: the operation returned")
    exit(1)
}

check(CGPathFillRule.winding != CGPathFillRule.evenOdd, "fill rules differ")
check(CGPathFillRule(rawValue: CGPathFillRule.evenOdd.rawValue) == .evenOdd, "CGPathFillRule is RawRepresentable")

print(failures == 0 ? "ALL PASS" : "\(failures) FAILED")
exit(failures == 0 ? 0 : 1)
