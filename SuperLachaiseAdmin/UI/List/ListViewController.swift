//
//  ListViewController.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 02/12/2017.
//

import Cocoa
import RxSwift

protocol ListViewControllerType: NSObjectProtocol {

    var didSingleClickModel: Observable<MainWindowModel> { get }

    var didDoubleClickModel: Observable<MainWindowModel> { get }

    var searchValue: String? { get set }

}

final class ListViewController: NSViewController, ListViewControllerType {

    // MARK: Dependencies

    lazy var realmContext = AppContainer.realmContext

    lazy var taskController = AppContainer.taskController

    // MARK: Model

    var rootItem: ListViewRootItem?

    // MARK: Properties

    var didSingleClickModel: Observable<MainWindowModel> {
        return didSingleClickModelSubject.asObservable()
    }

    var didDoubleClickModel: Observable<MainWindowModel> {
        return didDoubleClickModelSubject.asObservable()
    }

    let didSingleClickModelSubject = PublishSubject<MainWindowModel>()

    let didDoubleClickModelSubject = PublishSubject<MainWindowModel>()

    var shouldPerformSingleClickAction = false

    var searchValue: String? {
        didSet {
            rootItem?.filter = searchValue ?? ""
        }
    }

    // MARK: Subviews

    @IBOutlet var outlineView: NSOutlineView?

    // Lifecycle

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

}
