//
//  CoreDataEntry.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 10/11/2018.
//

import CoreData
import Foundation

final class CoreDataEntry: NSManagedObject {

    @NSManaged var id: String

    @NSManaged var name: String?
    @NSManaged var rawKind: String

    // Stored in UTC
    @NSManaged var rawDateOfBirth: Date?
    @NSManaged var rawDateOfBirthPrecision: String
    @NSManaged var rawDateOfDeath: Date?
    @NSManaged var rawDateOfDeathPrecision: String

    @NSManaged var localizations: Set<CoreDataLocalizedEntry>
    @NSManaged var mainEntryOf: Set<CoreDataPointOfInterest>
    @NSManaged var secondaryEntryOf: Set<CoreDataPointOfInterest>
    @NSManaged var image: CoreDataCommonsFile?
    @NSManaged var categories: Set<CoreDataCategory>

    override var description: String {
        return [name, id]
            .compactMap { $0 }
            .joined(separator: " - ")
    }

}
