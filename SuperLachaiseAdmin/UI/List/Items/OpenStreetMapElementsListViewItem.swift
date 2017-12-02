//
//  OpenStreetMapElementsListViewItem.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 02/12/2017.
//

import Cocoa
import RealmSwift
import RxSwift

final class OpenStreetMapElementsListViewItem: NSObject, ListViewItem {

    // MARK: ListViewItem

    let text: String = "OpenStreetMap elements"

    lazy var children: Variable<[ListViewItem]>? = {
        do {
            let realm = try Realm()
            let children = realm.objects(OpenStreetMapElement.self)
                .filter("toBeDeleted == false")
                .sorted(byKeyPath: "rawOpenStreetMapId")
                .map { OpenStreetMapElementListViewItem(openStreetMapElement: $0) }
            return Variable(Array(children))
        } catch {
            assertionFailure("\(error)")
            return Variable([])
        }
    }()

    // MARK: Equatable

    override func isEqual(_ object: Any?) -> Bool {
        return object is OpenStreetMapElementsListViewItem
    }

}
