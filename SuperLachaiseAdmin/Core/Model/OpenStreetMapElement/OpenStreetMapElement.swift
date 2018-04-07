//
//  OpenStreetMapElement.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 28/11/2017.
//

import Foundation
import RealmSwift

final class OpenStreetMapElement: Object {

    // Serialized as type/numericId
    @objc dynamic var rawOpenStreetMapId = ""

    @objc dynamic var latitude: Double = 0
    @objc dynamic var longitude: Double = 0
    @objc dynamic var name: String?

    @objc dynamic var wikidataEntry: WikidataEntry?

    @objc dynamic var isDeleted = false

    override static func primaryKey() -> String {
        return "rawOpenStreetMapId"
    }

    override var description: String {
        return [name, rawOpenStreetMapId]
            .compactMap { $0 }
            .joined(separator: " - ")
    }

}
