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

// IndexPath's NSCollectionView accessors, from the open-source Swift overlay (swiftlang/swift tag swift-5.2.2-RELEASE,
// stdlib/public/Darwin/AppKit/AppKit_FoundationExtensions.swift:16-50), unchanged apart from the imports.
// NEEDS-REAL-MAC: macOS 26 may have changed the preconditions.

@_exported import Foundation

extension IndexPath {
    
    /// Initialize for use with `NSCollectionView`.
    public init(item: Int, section: Int) {
        self.init(indexes: [section, item])
    }
    
    /// The item of this index path, when used with `NSCollectionView`.
    ///
    /// - precondition: The index path must have exactly two elements.
    public var item : Int {
        get {
            precondition(count == 2, "Invalid index path for use with NSCollectionView. This index path must contain exactly two indices specifying the section and item.")
            return self[1]
        }
        set {
            precondition(count == 2, "Invalid index path for use with NSCollectionView. This index path must contain exactly two indices specifying the section and item.")
            self[1] = newValue
        }
    }
    
    /// The section of this index path, when used with `NSCollectionView`.
    ///
    /// - precondition: The index path must have exactly two elements.
    public var section : Int {
        get {
            precondition(count == 2, "Invalid index path for use with NSCollectionView. This index path must contain exactly two indices specifying the section and item.")
            return self[0]
        }
        set {
            precondition(count == 2, "Invalid index path for use with NSCollectionView. This index path must contain exactly two indices specifying the section and item.")
            self[0] = newValue
        }
    }
}
