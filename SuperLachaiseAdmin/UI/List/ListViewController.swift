//
//  ListViewController.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 02/12/2017.
//

import Cocoa
import RealmSwift

protocol ListViewControllerType {

    var didSelectRootViewSource: ((Object & RootViewSource) -> Void)? { get set }

}

final class ListViewController: NSViewController, ListViewControllerType {

    // MARK: Dependencies

    lazy var realmContext = AppContainer.realmContext

    lazy var taskController = AppContainer.taskController

    // MARK: Properties

    var didSelectRootViewSource: ((Object & RootViewSource) -> Void)?

    // MARK: Subviews

    @IBOutlet weak var searchField: NSSearchField?

    @IBOutlet weak var outlineView: NSOutlineView?

    @IBOutlet weak var contextualMenu: NSMenu?

    // MARK: Model

    var rootItem: ListViewRootItem?

    // Lifecycle

    override func viewDidAppear() {
        super.viewDidAppear()
        searchField?.refusesFirstResponder = false
    }

    override func viewWillAppear() {
        super.viewWillAppear()
        self.rootItem = ListViewRootItem(realm: self.realmContext.viewRealm)
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

    func outlineViewSelectionDidChange(_ notification: Notification) {
        guard let outlineView = outlineView else {
            return
        }
        if let item = outlineView.item(atRow: outlineView.selectedRow) as? ListViewObjectItem,
            let rootViewSource = item.object as? (Object & RootViewSource) {
            didSelectRootViewSource?(rootViewSource)
        }
    }

}
