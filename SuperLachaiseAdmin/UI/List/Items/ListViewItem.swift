//
//  ListViewItem.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 02/12/2017.
//

import Cocoa

protocol ListViewItem: NSObjectProtocol {

    var identifier: String { get }

    var text: String { get }

    var children: [ListViewItem]? { get }

}

extension ListViewItem {

    func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? ListViewItem else {
            return false
        }
        return type(of: self) == type(of: object) && identifier == object.identifier
    }

}
