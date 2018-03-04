//
//  WikidataEntry.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 10/12/2017.
//

import Foundation
import RealmSwift

final class WikidataEntry: Object {

    @objc dynamic var wikidataId: String = ""

    @objc dynamic var name: String?
    @objc dynamic var rawNature = ""

    @objc dynamic var image: CommonsFile?
    @objc dynamic var imageOfGrave: CommonsFile? // for persons

    // Stored in UTC
    @objc dynamic var rawDateOfBirth: Date?
    @objc dynamic var rawDateOfBirthPrecision = ""
    @objc dynamic var rawDateOfDeath: Date?
    @objc dynamic var rawDateOfDeathPrecision = ""

    let secondaryWikidataIds = List<String>()
    let wikidataCategoriesIds = List<String>()
    let localizations = LinkingObjects(fromType: WikidataLocalizedEntry.self, property: "wikidataEntry")

    @objc dynamic var deleted = false

    override static func primaryKey() -> String {
        return "wikidataId"
    }

    override var description: String {
        return [name, wikidataId]
            .flatMap { $0 }
            .joined(separator: " - ")
    }

}
