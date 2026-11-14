// CGPathFillRule and the CGPath boolean operations union(_:using:), intersection(_:using:) and
// subtracting(_:using:), whose Swift declarations Apple documents
// (developer.apple.com/documentation/coregraphics/cgpath/union(_:using:) and its two siblings:
// `func union(_ other: CGPath, using rule: CGPathFillRule = .winding) -> CGPath`).
//
// CGPathFillRule is the declaration in swiftlang/swift release/5.4, stdlib/public/Darwin/CoreGraphics/CoreGraphics.swift
// (`public enum CGPathFillRule: Int { case winding; case evenOdd }`; Copyright (c) 2014 - 2017 Apple Inc. and the
// Swift project authors; Apache License v2.0 with Runtime Library Exception), without its documentation comments.
// A real Mac confirms the raw type and values: Int, winding 0, evenOdd 1 (probe symbols_b_probe1.txt lines 15-16).
//
// Podcasts imports all three methods. Darling's CoreGraphics exports no C function for path boolean operations (no
// CGPathCreateCopyByUnioningPath and so on), so the methods are declared and trap with a message naming the
// operation, the way open PR #106 does for CGPath.copy(dashingWithPhase:lengths:transform:)'s NULL-returning stub.

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
