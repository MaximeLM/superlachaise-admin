//
//  WikidataEntry.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 07/11/2018.
//

import CoreData
import Foundation

final class WikidataEntry: NSManagedObject {

    @NSManaged var id: String

    @NSManaged var name: String?
    @NSManaged var rawKind: String

    @NSManaged var image: CommonsFile?
    @NSManaged var imageOfGrave: CommonsFile? // for persons

    // Stored in UTC
    @NSManaged var rawDateOfBirth: Date?
    @NSManaged var rawDateOfBirthPrecision: String
    @NSManaged var rawDateOfDeath: Date?
    @NSManaged var rawDateOfDeathPrecision: String

    @NSManaged var openStreetMapElements: Set<OpenStreetMapElement>
    @NSManaged var secondaryWikidataEntries: Set<WikidataEntry>
    @NSManaged var secondaryWikidataEntryOf: Set<WikidataEntry>
    @NSManaged var localizations: Set<WikidataLocalizedEntry>
    @NSManaged var wikidataCategories: Set<WikidataCategory>

    override var description: String {
        return [name, id]
            .compactMap { $0 }
            .joined(separator: " - ")
    }

}
