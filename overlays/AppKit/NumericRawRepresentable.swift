//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2014 - 2017 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//

// _AppKitKitNumericRawRepresentable and its operators, from the open-source Swift overlay (swiftlang/swift tag
// swift-5.2.2-RELEASE, stdlib/public/Darwin/AppKit/AppKit.swift:109-142), unchanged. Only the conformances that
// macOS 26 apps import are declared (NSLayoutConstraint.Priority and NSToolbarItem.VisibilityPriority); the 5.2.2 source
// also conforms NSAppKitVersion, NSStackView.VisibilityPriority, NSTouchBarItem.Priority, NSWindow.Level and NSFont.Weight.
// NEEDS-REAL-MAC: whether macOS 26 still declares exactly this requirement set.

@_exported import Foundation
#if DARLING_APPKIT_CLANG_MODULE
@_exported import AppKit
#else
import _DarlingAppKitShims
#endif

public protocol _AppKitKitNumericRawRepresentable : RawRepresentable, Comparable
  where RawValue: Comparable & Numeric { }

extension _AppKitKitNumericRawRepresentable {
  public static func <(lhs: Self, rhs: Self) -> Bool {
    return lhs.rawValue < rhs.rawValue
  }

  public static func +(lhs: Self, rhs: RawValue) -> Self {
    return Self(rawValue: lhs.rawValue + rhs)!
  }

  public static func +(lhs: RawValue, rhs: Self) -> Self {
    return Self(rawValue: lhs + rhs.rawValue)!
  }

  public static func -(lhs: Self, rhs: RawValue) -> Self {
    return Self(rawValue: lhs.rawValue - rhs)!
  }

  public static func -(lhs: Self, rhs: Self) -> RawValue {
    return lhs.rawValue - rhs.rawValue
  }

  public static func +=(lhs: inout Self, rhs: RawValue) {
    lhs = Self(rawValue: lhs.rawValue + rhs)!
  }

  public static func -=(lhs: inout Self, rhs: RawValue) {
    lhs = Self(rawValue: lhs.rawValue - rhs)!
  }
}

@available(swift 4)
extension NSLayoutConstraint.Priority : _AppKitKitNumericRawRepresentable { }

@available(swift 4)
extension NSToolbarItem.VisibilityPriority : _AppKitKitNumericRawRepresentable { }
