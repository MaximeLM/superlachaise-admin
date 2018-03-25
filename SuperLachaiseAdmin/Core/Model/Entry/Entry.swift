//
//  Entry.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 25/03/2018.
//

import Foundation
import RealmSwift

final class Entry: Object {

    @objc dynamic var wikidataId: String = ""

    @objc dynamic var name: String?
    @objc dynamic var rawKind = ""

    // Stored in UTC
    @objc dynamic var rawDateOfBirth: Date?
    @objc dynamic var rawDateOfBirthPrecision = ""
    @objc dynamic var rawDateOfDeath: Date?
    @objc dynamic var rawDateOfDeathPrecision = ""

    let localizations = LinkingObjects(fromType: LocalizedEntry.self, property: "entry")

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
