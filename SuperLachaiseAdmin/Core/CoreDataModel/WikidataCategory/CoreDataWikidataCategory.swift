//
//  CoreDataWikidataCategory.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 10/11/2018.
//

import CoreData
import Foundation

final class CoreDataWikidataCategory: NSManagedObject {

    @NSManaged var id: String

    @NSManaged var name: String?

    @NSManaged var wikidataEntries: Set<CoreDataWikidataEntry>

    override var description: String {
        return [name, id]
            .compactMap { $0 }
            .joined(separator: " - ")
    }

}
