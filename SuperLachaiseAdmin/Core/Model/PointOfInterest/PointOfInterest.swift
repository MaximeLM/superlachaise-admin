//
//  PointOfInterest.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 03/12/2017.
//

import Foundation
import RealmSwift

final class PointOfInterest: Object {

    // Wikidata ID is used (more stable than OpenStreetMap ID)
    @objc dynamic var id = ""

    // For debugging (not localized)
    @objc dynamic var name: String?

    @objc dynamic var openStreetMapElement: OpenStreetMapElement?
    @objc dynamic var mainEntry: Entry?
    let secondaryEntries = List<Entry>()
    @objc dynamic var image: CommonsFile?

    override static func primaryKey() -> String {
        return "id"
    }

    override var description: String {
        return [name, id]
            .compactMap { $0 }
            .joined(separator: " - ")
    }

}
