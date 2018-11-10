//
//  PointOfInterest.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 10/11/2018.
//

import CoreData
import Foundation

final class PointOfInterest: NSManagedObject {

    // Wikidata ID is used (more stable than OpenStreetMap ID)
    @NSManaged var id: String

    // For debugging (not localized)
    @NSManaged var name: String?

    @NSManaged var openStreetMapElement: OpenStreetMapElement?
    @NSManaged var mainEntry: Entry?
    @NSManaged var secondaryEntries: Set<Entry>
    @NSManaged var image: CommonsFile?

    @NSManaged var databaseV1Mappings: Set<DatabaseV1Mapping>

    override var description: String {
        return [name, id]
            .compactMap { $0 }
            .joined(separator: " - ")
    }

}
