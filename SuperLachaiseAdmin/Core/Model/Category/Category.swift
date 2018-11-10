//
//  Category.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 10/11/2018.
//

import CoreData
import Foundation

final class Category: NSManagedObject {

    @NSManaged var id: String

    @NSManaged var localizations: Set<LocalizedCategory>
    @NSManaged var wikidataCategories: Set<WikidataCategory>
    @NSManaged var entries: Set<Entry>

    override var description: String {
        return "\(id) (\(entries.count))"
    }

}
