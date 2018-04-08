//
//  Entry.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 25/03/2018.
//

import Foundation
import RealmSwift

final class Entry: Object {

    @objc dynamic var id = ""

    @objc dynamic var name: String?
    @objc dynamic var rawKind = ""

    // Stored in UTC
    @objc dynamic var rawDateOfBirth: Date?
    @objc dynamic var rawDateOfBirthPrecision = ""
    @objc dynamic var rawDateOfDeath: Date?
    @objc dynamic var rawDateOfDeathPrecision = ""

    let localizations = LinkingObjects(fromType: LocalizedEntry.self, property: "entry")
    let mainEntryOf = LinkingObjects(fromType: PointOfInterest.self, property: "mainEntry")
    let secondayEntryOf = LinkingObjects(fromType: PointOfInterest.self, property: "secondaryEntries")
    @objc dynamic var image: CommonsFile?
    let categories = List<Category>()

    override static func primaryKey() -> String {
        return "id"
    }

    override var description: String {
        return [name, id]
            .compactMap { $0 }
            .joined(separator: " - ")
    }

}
