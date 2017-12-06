//
//  OpenStreetMapElement.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 28/11/2017.
//

import Foundation
import RealmSwift

final class OpenStreetMapElement: Object {

    // MARK: Properties

    // Serialized as type/numericId
    @objc dynamic var rawOpenStreetMapId: String?

    @objc dynamic var latitude: Double = 0
    @objc dynamic var longitude: Double = 0

    @objc dynamic var name: String?
    @objc dynamic var wikidataId: String?

    @objc dynamic var toBeDeleted = false

    override static func primaryKey() -> String {
        return "rawOpenStreetMapId"
    }

    override var description: String {
        return [name, rawOpenStreetMapId]
            .flatMap { $0 }
            .joined(separator: " - ")
    }

}
