//
//  CoreDataOpenStreetMapElement.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 07/11/2018.
//

import CoreData
import Foundation

final class CoreDataOpenStreetMapElement: NSManagedObject {

    // "type/numericId"
    @NSManaged var id: String

    @NSManaged var latitude: Double
    @NSManaged var longitude: Double
    @NSManaged var name: String?

    @NSManaged public var wikidataEntry: CoreDataWikidataEntry?

    override var description: String {
        return [name, id]
            .compactMap { $0 }
            .joined(separator: " - ")
    }

}
