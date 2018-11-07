//
//  ListViewObjectListItem.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 02/12/2017.
//

import Cocoa
import CoreData

final class ListViewObjectListItem<Element: MainWindowModel & CoreDataListable>: NSObject, ListViewItem {

    let baseText: String

    init(baseText: String, context: NSManagedObjectContext, filter: String) {
        self.baseText = baseText
        self.identifier = "ListViewObjectListItem.\(Element.self)"
        self.children = Element.list(filter: filter, context: context).map {
            ListViewObjectItem(object: $0)
        }
    }

    // MARK: ListViewItem

    let identifier: String

    var text: String {
        return "\(baseText) (\(children?.count ?? 0))"
    }

    let children: [ListViewItem]?

}
