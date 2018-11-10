//
//  Entry.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 10/11/2018.
//

import CoreData
import Foundation

final class Entry: NSManagedObject {

    @NSManaged var id: String

    @NSManaged var name: String?
    @NSManaged var rawKind: String

    // Stored in UTC
    @NSManaged var rawDateOfBirth: Date?
    @NSManaged var rawDateOfBirthPrecision: String
    @NSManaged var rawDateOfDeath: Date?
    @NSManaged var rawDateOfDeathPrecision: String

    @NSManaged var localizations: Set<LocalizedEntry>
    @NSManaged var mainEntryOf: Set<PointOfInterest>
    @NSManaged var secondaryEntryOf: Set<PointOfInterest>
    @NSManaged var image: CommonsFile?
    @NSManaged var categories: Set<Category>

    override var description: String {
        return [name, id]
            .compactMap { $0 }
            .joined(separator: " - ")
    }

}
