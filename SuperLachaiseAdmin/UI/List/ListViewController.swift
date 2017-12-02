//
//  ListViewController.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 02/12/2017.
//

import Cocoa

final class ListViewController: NSViewController {

    // MARK: Dependencies

    var realmContext: RealmContext?

    // MARK: Subviews

    @IBOutlet private weak var searchField: NSSearchField?

    @IBOutlet private weak var outlineView: NSOutlineView?

    // MARK: Model

    lazy var rootItem = RootListViewItem()

    // Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        searchField?.refusesFirstResponder = true
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        searchField?.refusesFirstResponder = false
    }

}

extension ListViewController: NSOutlineViewDataSource, NSOutlineViewDelegate {

    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        let itemModel = item as? ListViewItem ?? rootItem
        return itemModel.children?.value[index] ?? ""
    }

    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        let itemModel = item as? ListViewItem ?? rootItem
        return itemModel.children?.value.count ?? 0
    }

    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        let itemModel = item as? ListViewItem ?? rootItem
        return itemModel.children != nil
    }

    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        let itemModel = item as? ListViewItem ?? rootItem
        let viewIdentifier = NSUserInterfaceItemIdentifier(rawValue: "ItemView")
        guard let view = outlineView.makeView(withIdentifier: viewIdentifier, owner: self) as? NSTableCellView else {
            assertionFailure()
            return nil
        }
        let text = itemModel.text
        view.textField?.stringValue = text
        view.toolTip = text
        return view
    }

}
