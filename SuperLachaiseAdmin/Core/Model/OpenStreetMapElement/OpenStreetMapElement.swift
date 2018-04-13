//
//  OpenStreetMapElement.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 28/11/2017.
//

import Foundation
import RealmSwift

final class OpenStreetMapElement: Object {

    // "type/numericId"
    @objc dynamic var id = ""

    @objc dynamic var latitude: Double = 0
    @objc dynamic var longitude: Double = 0
    @objc dynamic var name: String?

    @objc dynamic var wikidataEntry: WikidataEntry?

    override static func primaryKey() -> String {
        return "id"
    }

    override var description: String {
        return [name, id]
            .compactMap { $0 }
            .joined(separator: " - ")
    }

}
