//
//  LocalizedEntry.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 10/11/2018.
//

import CoreData
import Foundation

final class LocalizedEntry: NSManagedObject {

    @NSManaged var language: String

    @NSManaged var name: String
    @NSManaged var summary: String
    @NSManaged var defaultSort: String

    @NSManaged var wikipediaPage: WikipediaPage?

    @NSManaged var entry: WikipediaPage?

    override var description: String {
        return [name, language]
            .compactMap { $0 }
            .joined(separator: " - ")
    }

}
