//
//  CoreDataLocalizedEntry.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 10/11/2018.
//

import CoreData
import Foundation

final class CoreDataLocalizedEntry: NSManagedObject {

    @NSManaged var language: String

    @NSManaged var name: String
    @NSManaged var summary: String
    @NSManaged var defaultSort: String

    @NSManaged var wikipediaPage: CoreDataWikipediaPage?

    @NSManaged var entry: CoreDataWikipediaPage?

    override var description: String {
        return [name, language]
            .compactMap { $0 }
            .joined(separator: " - ")
    }

}
