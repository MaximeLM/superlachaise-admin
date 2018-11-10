//
//  ListViewObjectListItem.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 02/12/2017.
//

import Cocoa
import CoreData

protocol ListViewObjectListItemType: ListViewItem {

    func reload(outlineView: NSOutlineView, context: NSManagedObjectContext, filter: String)

}

final class ListViewObjectListItem<Element: MainWindowModel & CoreDataListable>: NSObject, ListViewObjectListItemType {

    let baseText: String

    init(baseText: String) {
        self.baseText = baseText
        self.identifier = "ListViewObjectListItem.\(Element.self)"
        self.children = nil
    }

    func reload(outlineView: NSOutlineView, context: NSManagedObjectContext, filter: String) {
        children = Element.list(filter: filter, context: context).map {
            ListViewObjectItem(object: $0)
        }

        let selectedItem = outlineView.item(atRow: outlineView.selectedRow) as? ListViewItem
        let isSelectedItemChildren = (outlineView.parent(forItem: selectedItem) as? ListViewItem)?.isEqual(self)
            ?? false
        outlineView.reloadItem(self, reloadChildren: true)

        if isSelectedItemChildren, let selectedItem = selectedItem,
            let row = children?.index(where: { $0.identifier == selectedItem.identifier }) {
            outlineView.selectRowIndexes([outlineView.row(forItem: self) + row + 1], byExtendingSelection: false)
        }
    }

    // MARK: ListViewItem

    let identifier: String

    var text: String {
        return "\(baseText) (\(children?.count ?? 0))"
    }

    var children: [ListViewItem]?

}
