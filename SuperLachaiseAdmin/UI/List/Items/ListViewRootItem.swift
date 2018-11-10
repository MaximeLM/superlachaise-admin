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
            ListViewObjectListItem<OpenStreetMapElement>(baseText: "OpenStreetMap elements"),
            ListViewObjectListItem<WikidataEntry>(baseText: "Wikidata entries"),
            ListViewObjectListItem<WikidataCategory>(baseText: "Wikidata categories"),
            ListViewObjectListItem<WikipediaPage>(baseText: "Wikipedia pages"),
            ListViewObjectListItem<CommonsFile>(baseText: "Commons files"),
            ListViewObjectListItem<Category>(baseText: "Categories"),
            ListViewObjectListItem<PointOfInterest>(baseText: "Points of interest"),
            ListViewObjectListItem<Entry>(baseText: "Entries"),
            ListViewObjectListItem<DatabaseV1Mapping>(baseText: "Database V1 mappings"),
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
