//
//  SuperLachaisePOI+Protocols.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 07/12/2017.
//

import Foundation
import RealmSwift

extension SuperLachaisePOI: RealmDeletable, RealmListable {

    // MARK: RealmDeletable

    func delete() {
        realm?.delete(self)
    }

    // MARK: RealmIdentifiable

    var identifier: String {
        return wikidataId
    }

    // MARK: RealmListable

    static func list(filter: String) -> (Realm) -> Results<SuperLachaisePOI> {
        return { realm in
            var results = realm.objects(SuperLachaisePOI.self)
                .filter("toBeDeleted == false")
                .sorted(by: [
                    SortDescriptor(keyPath: "name"),
                    SortDescriptor(keyPath: "wikidataId"),
                ])
            if !filter.isEmpty {
                let predicate = NSPredicate(format: "wikidataId contains[cd] %@ OR name contains[cd] %@",
                                            filter, filter)
                results = results.filter(predicate)
            }
            return results
        }
    }

}
