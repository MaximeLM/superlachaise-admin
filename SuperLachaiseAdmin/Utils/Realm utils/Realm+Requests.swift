//
//  Realm+Requests.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 29/11/2017.
//

import Foundation
import RealmSwift

extension Realm {

    func findOrCreateObject<Element: Object, KeyType>(ofType type: Element.Type,
                                                      forPrimaryKey key: KeyType) -> Element {
        if let object = object(ofType: type, forPrimaryKey: key) {
            return object
        } else {
            guard let primaryKeyProperty = type.primaryKey() else {
                fatalError("Type \(type) has no primary key")
            }
            return create(type, value: [primaryKeyProperty: key])
        }
    }

}
