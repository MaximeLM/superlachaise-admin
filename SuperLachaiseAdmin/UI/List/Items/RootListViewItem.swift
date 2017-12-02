//
//  RootListViewItem.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 02/12/2017.
//

import Cocoa
import RxSwift

final class RootListViewItem: NSObject, ListViewItem {

    // MARK: ListViewItem

    let text: String = ""

    lazy var children: Variable<[ListViewItem]>? = {
        Variable([
            OpenStreetMapElementsListViewItem(),
        ])
    }()

    // MARK: Equatable

    override func isEqual(_ object: Any?) -> Bool {
        return object is RootListViewItem
    }

}
