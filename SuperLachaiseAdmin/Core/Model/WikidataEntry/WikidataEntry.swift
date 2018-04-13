//
//  WikidataEntry.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 10/12/2017.
//

import Foundation
import RealmSwift

final class WikidataEntry: Object {

    @objc dynamic var id = ""

    @objc dynamic var name: String?
    @objc dynamic var rawKind = ""

    @objc dynamic var image: CommonsFile?
    @objc dynamic var imageOfGrave: CommonsFile? // for persons

    // Stored in UTC
    @objc dynamic var rawDateOfBirth: Date?
    @objc dynamic var rawDateOfBirthPrecision = ""
    @objc dynamic var rawDateOfDeath: Date?
    @objc dynamic var rawDateOfDeathPrecision = ""

    let secondaryWikidataEntries = List<WikidataEntry>()
    let wikidataCategories = List<WikidataCategory>()
    let localizations = LinkingObjects(fromType: WikidataLocalizedEntry.self, property: "wikidataEntry")

    override static func primaryKey() -> String {
        return "id"
    }

    override var description: String {
        return [name, id]
            .compactMap { $0 }
            .joined(separator: " - ")
    }

}
