//
//  CoreDataWikidataEntry.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 07/11/2018.
//

import CoreData
import Foundation

final class CoreDataWikidataEntry: NSManagedObject {

    @NSManaged var id: String

    @NSManaged var name: String?
    @NSManaged var rawKind: String

    @NSManaged var image: CoreDataCommonsFile?
    @NSManaged var imageOfGrave: CoreDataCommonsFile? // for persons

    // Stored in UTC
    @NSManaged var rawDateOfBirth: Date?
    @NSManaged var rawDateOfBirthPrecision: String
    @NSManaged var rawDateOfDeath: Date?
    @NSManaged var rawDateOfDeathPrecision: String

    @NSManaged var openStreetMapElements: Set<CoreDataOpenStreetMapElement>
    @NSManaged var secondaryWikidataEntries: Set<CoreDataWikidataEntry>
    @NSManaged var secondaryWikidataEntryOf: Set<CoreDataWikidataEntry>
    @NSManaged var localizations: Set<CoreDataWikidataLocalizedEntry>
    @NSManaged var wikidataCategories: Set<CoreDataWikidataCategory>

    override var description: String {
        return [name, id]
            .compactMap { $0 }
            .joined(separator: " - ")
    }

}
