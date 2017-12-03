//
//  OpenStreetMapElement.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 28/11/2017.
//

import Foundation
import RealmSwift

final class OpenStreetMapElement: Object, RealmDeletable, RealmListable {

    // MARK: Properties

    // Serialized as type/numericId
    @objc dynamic var rawOpenStreetMapId: String?

    @objc dynamic var latitude: Double = 0
    @objc dynamic var longitude: Double = 0

    @objc dynamic var name: String?
    @objc dynamic var wikidataId: String?

    // MARK: Overrides

    override static func primaryKey() -> String {
        return "rawOpenStreetMapId"
    }

    override var description: String {
        return [name, rawOpenStreetMapId]
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
        return rawOpenStreetMapId ?? ""
    }

    // MARK: RealmListable

    static func list(filter: String) -> (Realm) -> Results<OpenStreetMapElement> {
        return { realm in
            var results = realm.objects(OpenStreetMapElement.self)
                .filter("toBeDeleted == false")
                .sorted(by: [
                    SortDescriptor(keyPath: "name"),
                    SortDescriptor(keyPath: "rawOpenStreetMapId"),
                ])
            if !filter.isEmpty {
                let predicate = NSPredicate(format: "rawOpenStreetMapId contains[cd] %@ OR name contains[cd] %@",
                                            filter, filter)
                results = results.filter(predicate)
            }
            return results
        }
    }

}
