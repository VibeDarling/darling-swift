// CGPathFillRule and the CGPath boolean operations union(_:using:), intersection(_:using:) and
// subtracting(_:using:), whose Swift declarations Apple documents
// (developer.apple.com/documentation/coregraphics/cgpath/union(_:using:) and its two siblings:
// `func union(_ other: CGPath, using rule: CGPathFillRule = .winding) -> CGPath`).
//
// Podcasts imports all three. Darling's CoreGraphics exports no C function for path boolean operations
// (no CGPathCreateCopyByUnioningPath and so on), so the methods are declared and trap with a message naming
// the missing function, the way CGPath.copy(dashingWithPhase:lengths:transform:) does for its stub.
//
// GUESS / NEEDS-REAL-MAC, not in the public documentation: CGPathFillRule's raw type and values. The
// documentation gives `enum CGPathFillRule` with cases `winding` and `evenOdd`, conforming to Equatable,
// Hashable and RawRepresentable; Int with winding = 0 and evenOdd = 1 is a guess (the order of the cases).

public enum CGPathFillRule : Int {
  case winding = 0
  case evenOdd = 1
}

extension CGPath {
  public func union(_ other: CGPath, using rule: CGPathFillRule = .winding) -> CGPath {
    fatalError("CGPath.union(_:using:): path boolean operations are not implemented by Darling's CoreGraphics yet")
  }

  public func intersection(_ other: CGPath, using rule: CGPathFillRule = .winding) -> CGPath {
    fatalError("CGPath.intersection(_:using:): path boolean operations are not implemented by Darling's CoreGraphics yet")
  }

  public func subtracting(_ other: CGPath, using rule: CGPathFillRule = .winding) -> CGPath {
    fatalError("CGPath.subtracting(_:using:): path boolean operations are not implemented by Darling's CoreGraphics yet")
  }
}
