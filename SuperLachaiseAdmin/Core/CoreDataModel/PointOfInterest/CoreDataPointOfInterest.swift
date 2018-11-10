//
//  CoreDataPointOfInterest.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 10/11/2018.
//

import CoreData
import Foundation

final class CoreDataPointOfInterest: NSManagedObject {

    // Wikidata ID is used (more stable than OpenStreetMap ID)
    @NSManaged var id: String

    // For debugging (not localized)
    @NSManaged var name: String?

    @NSManaged var openStreetMapElement: CoreDataOpenStreetMapElement?
    //@NSManaged var mainEntry: Entry? // TODO
    //let secondaryEntries = List<Entry>() // TODO
    @NSManaged var image: CoreDataCommonsFile?

    override var description: String {
        return [name, id]
            .compactMap { $0 }
            .joined(separator: " - ")
    }

}
