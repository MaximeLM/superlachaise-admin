//
//  OpenStreetMapElementListViewItem.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 02/12/2017.
//

import Cocoa
import RxSwift

final class OpenStreetMapElementListViewItem: NSObject, ListViewItem {

    let openStreetMapElement: OpenStreetMapElement

    init(openStreetMapElement: OpenStreetMapElement) {
        self.openStreetMapElement = openStreetMapElement
    }

    // MARK: ListViewItem

    var text: String {
        return openStreetMapElement.description
    }

    let children: Variable<[ListViewItem]>? = nil

    // MARK: Equatable

    override func isEqual(_ object: Any?) -> Bool {
        guard let item = object as? OpenStreetMapElementListViewItem else {
            return false
        }
        return openStreetMapElement == item.openStreetMapElement
    }

}
