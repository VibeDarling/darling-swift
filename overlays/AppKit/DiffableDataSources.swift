// NSCollectionViewDiffableDataSource and NSTableViewDiffableDataSource. Applying a snapshot stores it and reloads
// the view; there is no diffing or animation, so `animatingDifferences` is accepted and ignored. Each class serves its
// view through Objective-C selectors rather than by declaring protocol conformance, because the protocols differ
// between Darling's AppKit headers and Apple's. The selector methods are internal: the view reaches them through the
// Objective-C runtime, and no app imports them.
//
// Provenance. Names: Reminders, Mail and App Store import both classes' type descriptors, initializers, the dispatch
// thunks of apply, snapshot(), numberOfRows(in:), itemIdentifier(forRow:), row(forItemIdentifier:), indexPath(for:),
// itemIdentifier(for:) and the supplementaryViewProvider setter, and the method descriptor of the table class's
// initializer (rung 5, llvm-nm -u -m; the table CellProvider is `(NSTableView, NSTableColumn, Int, ItemIdentifierType)
// -> NSView` as the mangled initializer states it). Declarations: Apple's public documentation,
// https://developer.apple.com/documentation/appkit/nscollectionviewdiffabledatasource-axww and
// .../nstableviewdiffabledatasource-c5gl: generic signature `<SectionIdentifierType: Hashable, ItemIdentifierType:
// Hashable>`, classes inheriting NSObject, ItemProvider and SupplementaryViewProvider spelled on the doc pages.
// Layout that cannot matter: both are open classes built with library evolution, so a subclass in an app reaches
// methods through exported method descriptors and the instance layout through runtime-computed offsets.
// Known limits: under Darling's AppKit apply() reloads eagerly, and Darling's NSCollectionView raises an Objective-C
// exception through the reload for any layout that is not an NSCollectionViewFlowLayout (compositional layouts
// included), and its NSTableView asks only its delegate for cell views, so a table that already has a delegate, or gets
// one later, never calls the cell provider.
// GUESS: that the classes are `open` (the documentation says `class`; the exported dispatch thunks and the initializer's
// method descriptor imply it); that apply stores the snapshot and reloads; that a table has one row per item (no
// section header rows); that the table class installs itself as delegate only when the table has none (Darling's
// NSTableView asks its delegate for cell views); that a missing item from the provider traps.
// Left out because no named app imports them: rowViewProvider, sectionHeaderViewProvider, defaultRowAnimation,
// sectionIdentifier(forRow:), row(forSectionIdentifier:) and the Reference classes.

@_exported import Foundation
#if DARLING_APPKIT_CLANG_MODULE
@_exported import AppKit
#else
import _DarlingAppKitShims
#endif

/// Provides the items of an `NSCollectionView` from a snapshot of identifiers.
open class NSCollectionViewDiffableDataSource<SectionIdentifierType: Hashable, ItemIdentifierType: Hashable>: NSObject {
    public typealias ItemProvider = (NSCollectionView, IndexPath, ItemIdentifierType) -> NSCollectionViewItem?
    public typealias SupplementaryViewProvider = (NSCollectionView, String, IndexPath) -> (NSView & NSCollectionViewElement)?

    private weak var host: NSCollectionView?
    private let itemProvider: ItemProvider
    private var current = NSDiffableDataSourceSnapshot<SectionIdentifierType, ItemIdentifierType>()

    /// Called for each supplementary view the collection view asks for.
    open var supplementaryViewProvider: SupplementaryViewProvider?

    public init(collectionView: NSCollectionView, itemProvider: @escaping ItemProvider) {
        self.host = collectionView
        self.itemProvider = itemProvider
        super.init()
        collectionView.dataSource = self
    }

    /// The snapshot last applied.
    open func snapshot() -> NSDiffableDataSourceSnapshot<SectionIdentifierType, ItemIdentifierType> {
        return current
    }

    open func apply(_ snapshot: NSDiffableDataSourceSnapshot<SectionIdentifierType, ItemIdentifierType>,
                    animatingDifferences: Bool = true, completion: (() -> Void)? = nil) {
        current = snapshot
        host?.reloadData()
        completion?()
    }

    /// The identifier of the item at `indexPath`, or `nil` when the path is outside the snapshot.
    open func itemIdentifier(for indexPath: IndexPath) -> ItemIdentifierType? {
        guard indexPath.count == 2 else { return nil }
        return current.itemIdentifier(atSectionIndex: indexPath[0], item: indexPath[1])
    }

    /// The path of the item with `identifier`, or `nil` when it is not in the snapshot.
    open func indexPath(for identifier: ItemIdentifierType) -> IndexPath? {
        guard let section = current.sectionIdentifier(containingItem: identifier),
              let sectionIndex = current.indexOfSection(section),
              let row = current.indexOfItem(identifier) else { return nil }
        let first = current.sectionIdentifiers[..<sectionIndex].reduce(0) { $0 + current.numberOfItems(inSection: $1) }
        return IndexPath(item: row - first, section: sectionIndex)
    }

    @objc(numberOfSectionsInCollectionView:)
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return current.numberOfSections
    }

    @objc(collectionView:numberOfItemsInSection:)
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return section >= 0 && section < current.numberOfSections ? current.numberOfItems(atSectionIndex: section) : 0
    }

    @objc(collectionView:itemForRepresentedObjectAtIndexPath:)
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        guard let identifier = itemIdentifier(for: indexPath),
              let item = itemProvider(collectionView, indexPath, identifier) else {
            preconditionFailure("The item provider returned no item for \(indexPath)")
        }
        return item
    }

    @objc(collectionView:viewForSupplementaryElementOfKind:atIndexPath:)
    func collectionView(_ collectionView: NSCollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> NSView {
        guard let provider = supplementaryViewProvider, let view = provider(collectionView, kind, indexPath) else {
            preconditionFailure("The supplementary view provider returned no view for \(kind) at \(indexPath)")
        }
        return view
    }
}

/// Provides the rows of an `NSTableView` from a snapshot of identifiers.
open class NSTableViewDiffableDataSource<SectionIdentifierType: Hashable, ItemIdentifierType: Hashable>: NSObject {
    public typealias CellProvider = (NSTableView, NSTableColumn, Int, ItemIdentifierType) -> NSView

    private weak var host: NSTableView?
    private let cellProvider: CellProvider
    private var current = NSDiffableDataSourceSnapshot<SectionIdentifierType, ItemIdentifierType>()

    public init(tableView: NSTableView, cellProvider: @escaping CellProvider) {
        self.host = tableView
        self.cellProvider = cellProvider
        super.init()
        tableView.dataSource = self
        if tableView.delegate == nil { tableView.delegate = self }
    }

    /// The snapshot last applied.
    open func snapshot() -> NSDiffableDataSourceSnapshot<SectionIdentifierType, ItemIdentifierType> {
        return current
    }

    open func apply(_ snapshot: NSDiffableDataSourceSnapshot<SectionIdentifierType, ItemIdentifierType>,
                    animatingDifferences: Bool = true, completion: (() -> Void)? = nil) {
        current = snapshot
        host?.reloadData()
        completion?()
    }

    open func numberOfRows(in tableView: NSTableView) -> Int {
        return current.numberOfItems
    }

    /// The identifier of the item in `row`, or `nil` when the row is outside the snapshot.
    open func itemIdentifier(forRow row: Int) -> ItemIdentifierType? {
        return current.itemIdentifier(atRow: row)
    }

    /// The row of the item with `identifier`, or `nil` when it is not in the snapshot.
    open func row(forItemIdentifier identifier: ItemIdentifierType) -> Int? {
        return current.indexOfItem(identifier)
    }

    @objc(numberOfRowsInTableView:)
    func numberOfRowsInTableView(_ tableView: NSTableView) -> Int {
        return numberOfRows(in: tableView)
    }

    @objc(tableView:viewForTableColumn:row:)
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let tableColumn = tableColumn, let identifier = itemIdentifier(forRow: row) else { return nil }
        return cellProvider(tableView, tableColumn, row, identifier)
    }
}
