//
//  ListViewController.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 02/12/2017.
//

import Cocoa
import RealmSwift
import RxSwift

protocol ListViewControllerType: NSObjectProtocol {

    var selectedObjects: Observable<Object & RealmIdentifiable> { get }

}

final class ListViewController: NSViewController, ListViewControllerType {

    // MARK: Dependencies

    lazy var realmContext = AppContainer.realmContext

    lazy var taskController = AppContainer.taskController

    // MARK: Properties

    var selectedObjects: Observable<Object & RealmIdentifiable> {
        return _selectedObjects.asObservable()
    }

    private let _selectedObjects = PublishSubject<Object & RealmIdentifiable>()

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
            guard let outlineView = outlineView else {
                return
            }

            let selectedItem = outlineView.item(atRow: outlineView.selectedRow) as? ListViewItem
            let isSelectedItemChildren = (outlineView.parent(forItem: selectedItem) as? ListViewItem)?.isEqual(item)
                ?? false
            outlineView.reloadItem(item, reloadChildren: true)

            if isSelectedItemChildren, let selectedItem = selectedItem,
                let row = item.children?.index(where: { $0.identifier == selectedItem.identifier }) {
                outlineView.selectRowIndexes([outlineView.row(forItem: item) + row + 1], byExtendingSelection: false)
            }
        }

        return view
    }

    func outlineViewSelectionDidChange(_ notification: Notification) {
        guard let outlineView = outlineView else {
            return
        }
        if let item = outlineView.item(atRow: outlineView.selectedRow) as? ListViewObjectItem {
            _selectedObjects.onNext(item.object)
        }
    }

}
