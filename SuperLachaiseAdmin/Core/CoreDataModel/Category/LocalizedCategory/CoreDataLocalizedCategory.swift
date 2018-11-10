//
//  CoreDataLocalizedCategory.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 10/11/2018.
//

import CoreData
import Foundation

final class CoreDataLocalizedCategory: NSManagedObject {

    @NSManaged var language: String
    @NSManaged var name: String

    @NSManaged var category: CoreDataCategory?

    override var description: String {
        return [name, language]
            .compactMap { $0 }
            .joined(separator: " - ")
    }

}
