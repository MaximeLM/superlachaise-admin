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
            ListViewObjectListItem<CoreDataWikidataEntry>(baseText: "Wikidata entries"),
            ListViewObjectListItem<CoreDataWikidataCategory>(baseText: "Wikidata categories"),
            ListViewObjectListItem<CoreDataWikipediaPage>(baseText: "Wikipedia pages"),
            ListViewObjectListItem<CoreDataCommonsFile>(baseText: "Commons files"),
            ListViewObjectListItem<CoreDataCategory>(baseText: "Categories"),
            ListViewObjectListItem<CoreDataPointOfInterest>(baseText: "Points of interest"),
            ListViewObjectListItem<CoreDataEntry>(baseText: "Entries"),
            ListViewObjectListItem<CoreDataDatabaseV1Mapping>(baseText: "Database V1 mappings"),
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
