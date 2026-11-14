// NSCollectionViewDiffableDataSource and NSTableViewDiffableDataSource from the AppKit overlay, under Darling.
import AppKit
import _DarlingAppKitShims

var failures = 0
func check(_ condition: Bool, _ label: String) {
    print(condition ? "ok:" : "FAIL:", label)
    if !condition { failures += 1 }
}

// The views read the data through these selectors, which are internal to the overlay, so the test sends them the way
// the views do.
@objc protocol CollectionReader {
    @objc(numberOfSectionsInCollectionView:) func numberOfSections(in collectionView: NSCollectionView) -> Int
    @objc(collectionView:numberOfItemsInSection:) func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int
    @objc(collectionView:itemForRepresentedObjectAtIndexPath:) func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem
    @objc(collectionView:viewForSupplementaryElementOfKind:atIndexPath:) func collectionView(_ collectionView: NSCollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> NSView
}

@objc protocol TableReader {
    @objc(numberOfRowsInTableView:) func numberOfRowsInTableView(_ tableView: NSTableView) -> Int
    @objc(tableView:viewForTableColumn:row:) func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?
}

var snapshot = NSDiffableDataSourceSnapshot<String, Int>()
snapshot.appendSections(["a", "b"])
snapshot.appendItems([1, 2], toSection: "a")
snapshot.appendItems([3], toSection: "b")

// Collection view.
// Darling's NSCollectionView reloads eagerly and only with a flow layout, and loads each item's view.
let collectionView = NSCollectionView()
collectionView.collectionViewLayout = NSCollectionViewFlowLayout()
var itemRequests: [(IndexPath, Int)] = []
let collection = NSCollectionViewDiffableDataSource<String, Int>(collectionView: collectionView) { _, path, identifier in
    itemRequests.append((path, identifier))
    let item = NSCollectionViewItem()
    item.view = NSView()
    return item
}
check((collectionView.dataSource as AnyObject?) === collection, "collection: the view's data source is the object")
let reader = unsafeBitCast(collection, to: CollectionReader.self)
check(collection.snapshot().numberOfItems == 0, "collection: starts empty")
var completed = false
collection.apply(snapshot, animatingDifferences: false) { completed = true }
check(completed, "collection: apply calls its completion")
check(collection.snapshot().numberOfItems == 3, "collection: snapshot is stored")
// Darling's NSCollectionView reloads eagerly, so apply already asked the provider for every item, in order.
check(itemRequests.map { $0.1 } == [1, 2, 3], "collection: apply reloads the view, which asks for each item")
itemRequests.removeAll()
check(reader.numberOfSections(in: collectionView) == 2, "collection: sections")
check(reader.collectionView(collectionView, numberOfItemsInSection: 0) == 2, "collection: items in the first section")
check(reader.collectionView(collectionView, numberOfItemsInSection: 1) == 1, "collection: items in the second section")
check(reader.collectionView(collectionView, numberOfItemsInSection: 5) == 0, "collection: items in a missing section")
_ = reader.collectionView(collectionView, itemForRepresentedObjectAt: IndexPath(item: 0, section: 1))
check(itemRequests.count == 1 && itemRequests[0].0 == IndexPath(item: 0, section: 1) && itemRequests[0].1 == 3,
      "collection: the item provider gets the index path and the identifier")
check(collection.itemIdentifier(for: IndexPath(item: 1, section: 0)) == 2, "collection: item identifier for a path")
check(collection.itemIdentifier(for: IndexPath(item: 5, section: 0)) == nil, "collection: no identifier outside the snapshot")
check(collection.indexPath(for: 3) == IndexPath(item: 0, section: 1), "collection: path for an identifier")
check(collection.indexPath(for: 2) == IndexPath(item: 1, section: 0), "collection: path for the second item of a section")
check(collection.indexPath(for: 99) == nil, "collection: no path for an unknown identifier")

final class Element: NSView, NSCollectionViewElement {}
var suppRequests: [String] = []
check(collection.supplementaryViewProvider == nil, "collection: no supplementary provider at first")
collection.supplementaryViewProvider = { _, kind, _ in suppRequests.append(kind); return Element() }
check(reader.collectionView(collectionView, viewForSupplementaryElementOfKind: "header", at: IndexPath(item: 0, section: 0)) is Element
      && suppRequests == ["header"], "collection: the supplementary view provider is asked")

// Table view.
final class Subclass<S: Hashable, I: Hashable>: NSTableViewDiffableDataSource<S, I> {
    var applied = 0
    override func apply(_ snapshot: NSDiffableDataSourceSnapshot<S, I>, animatingDifferences: Bool = true, completion: (() -> Void)? = nil) {
        applied += 1
        super.apply(snapshot, animatingDifferences: animatingDifferences, completion: completion)
    }
}
let tableView = NSTableView()
let column = NSTableColumn()
var cellRequests: [(Int, Int)] = []
let table = Subclass<String, Int>(tableView: tableView) { _, _, row, identifier in
    cellRequests.append((row, identifier))
    return NSView()
}
let tableReader = unsafeBitCast(table, to: TableReader.self)
check((tableView.dataSource as AnyObject?) === table, "table: the view's data source is the object")
check((tableView.delegate as AnyObject?) === table, "table: the object is the delegate of a table that had none")
check(table.numberOfRows(in: tableView) == 0, "table: starts empty")
table.apply(snapshot)
check(table.applied == 1, "table: a subclass overrides apply")
check(table.snapshot().numberOfItems == 3 && table.numberOfRows(in: tableView) == 3, "table: one row per item")
check(tableReader.numberOfRowsInTableView(tableView) == 3, "table: the view asks through numberOfRowsInTableView:")
check(table.itemIdentifier(forRow: 2) == 3 && table.itemIdentifier(forRow: 3) == nil && table.itemIdentifier(forRow: -1) == nil,
      "table: item identifier for a row")
check(table.row(forItemIdentifier: 2) == 1 && table.row(forItemIdentifier: 99) == nil, "table: row for an identifier")
_ = tableReader.tableView(tableView, viewFor: column, row: 1)
check(cellRequests.count == 1 && cellRequests[0] == (1, 2), "table: the cell provider gets the row and the identifier")
check(tableReader.tableView(tableView, viewFor: column, row: 9) == nil, "table: no view outside the snapshot")

if failures != 0 { exit(1) }
