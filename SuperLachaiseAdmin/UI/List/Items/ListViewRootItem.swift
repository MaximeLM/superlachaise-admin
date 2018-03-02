//
//  ListViewRootItem.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 02/12/2017.
//

import Cocoa
import RealmSwift

final class ListViewRootItem: NSObject, ListViewItem {

    let realm: Realm

    init(realm: Realm) {
        self.realm = realm
    }

    var filter: String = "" {
        didSet {
            _children.forEach { $0.filter = filter }
        }
    }

    // MARK: ListViewItem

    let identifier: String = "RootListViewItem"

    let text: String = ""

    var children: [ListViewItem]? {
        return _children
    }

    var reload: ((ListViewItem) -> Void)?

    // MARK: Private

    private lazy var _children: [ListViewObjectListItemType] = { [unowned self] in
        [
            ListViewObjectListItem<SuperLachaisePOI>(baseText: "SuperLachaise POIs",
                                                     realm: self.realm, filter: self.filter),
            ListViewObjectListItem<OpenStreetMapElement>(baseText: "OpenStreetMap elements",
                                                         realm: self.realm, filter: self.filter),
            ListViewObjectListItem<WikidataEntry>(baseText: "Wikidata entries",
                                                  realm: self.realm, filter: self.filter),
            ListViewObjectListItem<WikipediaPage>(baseText: "Wikipedia pages",
                                                  realm: self.realm, filter: self.filter),
            ListViewObjectListItem<CommonsFile>(baseText: "Commons files",
                                                realm: self.realm, filter: self.filter),
        ]
    }()

}
