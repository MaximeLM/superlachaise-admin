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

    var taskController: TaskController?

    // MARK: Subviews

    @IBOutlet weak var searchField: NSSearchField?

    @IBOutlet weak var outlineView: NSOutlineView?

    // MARK: Model

    var rootItem: ListViewRootItem?

    // Lifecycle

    override func viewDidAppear() {
        super.viewDidAppear()
        searchField?.refusesFirstResponder = false
    }

    override func viewWillAppear() {
        super.viewWillAppear()
        guard let realm = self.realmContext?.viewRealm else {
            fatalError("realmContext not set")
        }
        self.rootItem = ListViewRootItem(realm: realm)
        outlineView?.reloadData()
    }

}

extension ListViewController: NSOutlineViewDataSource, NSOutlineViewDelegate {

    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        let itemModel = item as? ListViewItem ?? rootItem
        return itemModel?.children?.count ?? 0
    }

    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        let itemModel = item as? ListViewItem ?? rootItem
        return itemModel?.children?[index] ?? NSNull()
    }

    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        let itemModel = item as? ListViewItem ?? rootItem
        return itemModel?.children != nil
    }

    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        guard let itemModel = item as? ListViewItem ?? rootItem else {
            return nil
        }

        let viewIdentifier = NSUserInterfaceItemIdentifier(rawValue: "ItemView")
        guard let view = outlineView.makeView(withIdentifier: viewIdentifier, owner: self) as? NSTableCellView else {
            assertionFailure()
            return nil
        }

        let text = itemModel.text
        view.textField?.stringValue = text
        view.toolTip = text

        itemModel.reload = { [weak outlineView] item in
            outlineView?.reloadItem(item, reloadChildren: true)
        }

        return view
    }

}
