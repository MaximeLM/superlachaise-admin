//
//  ListViewController.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 02/12/2017.
//

import Cocoa
import RxSwift

protocol ListViewControllerType: NSObjectProtocol {

    var searchValue: String? { get set }

}

final class ListViewController: NSViewController, ListViewControllerType {

    // MARK: Dependencies

    lazy var realmContext = AppContainer.realmContext

    // MARK: Model

    var rootItem: ListViewRootItem?

    // MARK: Properties

    var pendingSelectedModel: MainWindowModel?

    var searchValue: String? {
        didSet {
            rootItem?.filter = searchValue ?? ""
        }
    }

    let disposeBag = DisposeBag()

    // MARK: Subviews

    @IBOutlet var outlineView: NSOutlineView?

    // Lifecycle

    override func viewWillAppear() {
        super.viewWillAppear()
        self.rootItem = ListViewRootItem(realm: self.realmContext.viewRealm)
        outlineView?.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        realmContext.viewRealmSaveNotification
            .subscribe(onNext: { [weak self] _ in
                self?.outlineView?.reloadData()
            })
            .disposed(by: disposeBag)

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
        // Cancel selection
        pendingSelectedModel = nil

        guard let outlineView = outlineView else {
            return
        }
        guard let item = outlineView.item(atRow: outlineView.selectedRow) as? ListViewObjectItem else {
            return
        }

        // Delay event to prevent collision with double click
        pendingSelectedModel = item.object
        let deadline: DispatchTime = .now() + .milliseconds(250)
        DispatchQueue.main.asyncAfter(deadline: deadline) {
            guard let pendingSelectedModel = self.pendingSelectedModel else {
                return
            }
            self.pendingSelectedModel = nil
            self.mainWindowController?.selectModelIfNeeded(pendingSelectedModel)
        }
    }

}
