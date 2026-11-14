// IndexPath(item:section:) and the item getter. Names: imported by Notes (rung 5, llvm-nm -u -m). Behaviour: a
// two-element path is [section, item], the layout Apple's public documentation of IndexPath(item:section:) gives.
// GUESS: the result of `item` on a path shorter than two indexes is not documented; the getter traps through the
// IndexPath subscript. `section` and the setters are left out: no named app imports them.

@_exported import Foundation

extension IndexPath {
    /// Creates a two-element index path for `item` within `section`.
    public init(item: Int, section: Int) {
        self.init(indexes: [section, item])
    }

    /// The item within the section, the second index of the path.
    public var item: Int {
        return self[1]
    }
}
