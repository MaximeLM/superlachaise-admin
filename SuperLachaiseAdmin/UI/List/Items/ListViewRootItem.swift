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

    // MARK: ListViewItem

    let identifier: String = "RootListViewItem"

    let text: String = ""

    lazy var children: [ListViewItem]? = { [unowned self] in
        [
            ListViewObjectListItem<SuperLachaisePOI>(baseText: "SuperLachaise POIs", realm: self.realm),
            ListViewObjectListItem<OpenStreetMapElement>(baseText: "OpenStreetMap elements", realm: self.realm),
        ]
    }()

    var reload: ((ListViewItem) -> Void)?

}
