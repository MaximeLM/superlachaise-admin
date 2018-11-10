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

    lazy var database = AppContainer.database

    // MARK: Model

    lazy var rootItem = ListViewRootItem()

    // MARK: Properties

    var pendingSelectedModel: MainWindowModel?

    var searchValue: String? {
        didSet {
            reload()
        }
    }

    let disposeBag = DisposeBag()

    func reload() {
        database.performInViewContext
            .subscribe(onSuccess: { context in
                guard let outlineView = self.outlineView else {
                    return
                }
                self.rootItem.reload(outlineView: outlineView, context: context, filter: self.searchValue ?? "")
            })
            .disposed(by: disposeBag)
    }

    // MARK: Subviews

    @IBOutlet var outlineView: NSOutlineView?

    // Lifecycle

    override func viewWillAppear() {
        super.viewWillAppear()
        reload()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        database.contextDidSave
            .subscribe(onNext: { [weak self] _ in
                self?.reload()
            })
            .disposed(by: disposeBag)

    }

}

extension ListViewController: NSOutlineViewDataSource, NSOutlineViewDelegate {

    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        let itemModel = item as? ListViewItem ?? rootItem
        return itemModel.children?.count ?? 0
    }

    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        let itemModel = item as? ListViewItem ?? rootItem
        return itemModel.children?[index] ?? NSNull()
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
