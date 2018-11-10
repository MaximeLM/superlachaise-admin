//
//  ListViewRootItem.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 02/12/2017.
//

import Cocoa
import CoreData

final class ListViewRootItem: NSObject, ListViewItem {

    override init() {
        self.children = [
            ListViewObjectListItem<CoreDataOpenStreetMapElement>(baseText: "OpenStreetMap elements"),
        ]
    }

    func reload(outlineView: NSOutlineView, context: NSManagedObjectContext, filter: String) {
        children?.compactMap({ $0 as? ListViewObjectListItemType }).forEach { child in
            child.reload(outlineView: outlineView, context: context, filter: filter)
        }
    }

    // MARK: ListViewItem

    let identifier: String = "RootListViewItem"

    let text = ""

    let children: [ListViewItem]?

}
