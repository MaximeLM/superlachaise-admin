//
//  CoreDataCategory.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 10/11/2018.
//

import CoreData
import Foundation

final class CoreDataCategory: NSManagedObject {

    @NSManaged var id: String

    @NSManaged var localizations: Set<CoreDataLocalizedCategory>
    @NSManaged var wikidataCategories: Set<CoreDataWikidataCategory>
    @NSManaged var entries: Set<CoreDataEntry>

    override var description: String {
        return "\(id) (\(entries.count))"
    }

}
