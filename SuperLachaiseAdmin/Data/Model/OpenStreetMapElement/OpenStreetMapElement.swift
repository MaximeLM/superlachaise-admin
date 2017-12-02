//
//  OpenStreetMapElement.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 28/11/2017.
//

import Foundation
import RealmSwift

final class OpenStreetMapElement: Object, RealmDeletable, RealmIdentifiable, RealmListable {

    // MARK: Properties

    // Serialized as type/numericId
    @objc dynamic var rawOpenStreetMapId: String?

    @objc dynamic var latitude: Double = 0
    @objc dynamic var longitude: Double = 0

    @objc dynamic var name: String?

    @objc dynamic var rawTags: Data?

    // MARK: Overrides

    override static func primaryKey() -> String {
        return "rawOpenStreetMapId"
    }

    override var description: String {
        return [rawOpenStreetMapId, name]
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

    static func list() -> (Realm) -> Results<OpenStreetMapElement> {
        return { realm in
            return realm.objects(OpenStreetMapElement.self)
                .filter("toBeDeleted == false")
                .sorted(byKeyPath: "rawOpenStreetMapId")
        }
    }

}
