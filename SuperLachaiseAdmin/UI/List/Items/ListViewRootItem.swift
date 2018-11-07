//
//  ListViewRootItem.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 02/12/2017.
//

import Cocoa
import CoreData

final class ListViewRootItem: NSObject, ListViewItem {

    init(filter: String, context: NSManagedObjectContext) {
        self.children = [
            ListViewObjectListItem<CoreDataOpenStreetMapElement>(baseText: "OpenStreetMap elements",
                                                                 context: context, filter: filter),
        ]
    }

    // MARK: ListViewItem

    let identifier: String = "RootListViewItem"

    let text = ""

    let children: [ListViewItem]?

    // MARK: Private

    /*private lazy var _children: [ListViewObjectListItemType] = { [unowned self] in
        [
            ListViewObjectListItem<OpenStreetMapElement>(baseText: "OpenStreetMap elements",
                                                         realm: self.realm, filter: self.filter),
            ListViewObjectListItem<WikidataEntry>(baseText: "Wikidata entries",
                                                  realm: self.realm, filter: self.filter),
            ListViewObjectListItem<WikidataCategory>(baseText: "Wikidata categories",
                                                     realm: self.realm, filter: self.filter),
            ListViewObjectListItem<WikipediaPage>(baseText: "Wikipedia pages",
                                                  realm: self.realm, filter: self.filter),
            ListViewObjectListItem<CommonsFile>(baseText: "Commons files",
                                                realm: self.realm, filter: self.filter),
            ListViewObjectListItem<Category>(baseText: "Categories",
                                             realm: self.realm, filter: self.filter),
            ListViewObjectListItem<PointOfInterest>(baseText: "Points of interest",
                                                    realm: self.realm, filter: self.filter),
            ListViewObjectListItem<Entry>(baseText: "Entries",
                                          realm: self.realm, filter: self.filter),
            ListViewObjectListItem<DatabaseV1Mapping>(baseText: "Database V1 mappings",
                                                      realm: self.realm, filter: self.filter),
        ]
    }()*/

}
