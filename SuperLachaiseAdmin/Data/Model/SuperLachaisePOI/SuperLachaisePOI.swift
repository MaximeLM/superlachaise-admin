//
//  SuperLachaisePOI.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 03/12/2017.
//

import Foundation
import RealmSwift

final class SuperLachaisePOI: Object, RealmDeletable, RealmListable {

    // MARK: Properties

    @objc dynamic var wikidataId: String = ""

    @objc dynamic var openStreetMapElement: OpenStreetMapElement?

    @objc dynamic var name: String?

    // MARK: Overrides

    override static func primaryKey() -> String {
        return "wikidataId"
    }

    override var description: String {
        return [name, wikidataId]
            .flatMap { $0 }
            .joined(separator: " - ")
    }

    // MARK: RealmDeletable

    @objc dynamic var toBeDeleted = false

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
