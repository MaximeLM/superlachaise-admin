//
//  WikidataCategory.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 10/11/2018.
//

import CoreData
import Foundation

final class WikidataCategory: NSManagedObject {

    @NSManaged var id: String

    @NSManaged var name: String?

    @NSManaged var wikidataEntries: Set<WikidataEntry>
    @NSManaged var categories: Set<Category>

    override var description: String {
        return [name, id]
            .compactMap { $0 }
            .joined(separator: " - ")
    }

}
