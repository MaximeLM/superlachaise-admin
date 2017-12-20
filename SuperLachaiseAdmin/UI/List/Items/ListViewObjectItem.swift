//
//  ListViewObjectItem.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 02/12/2017.
//

import Cocoa
import RealmSwift

final class ListViewObjectItem: NSObject, ListViewItem {

    let object: MainWindowModel

    init(object: MainWindowModel) {
        self.object = object
    }

    // MARK: ListViewItem

    var identifier: String {
        return object.identifier
    }

    var text: String {
        return object.description
    }

    var children: [ListViewItem]? {
        return nil
    }

    var reload: ((ListViewItem) -> Void)?

}
