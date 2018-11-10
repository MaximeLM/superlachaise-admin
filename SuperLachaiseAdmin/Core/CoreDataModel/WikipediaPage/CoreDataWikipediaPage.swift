//
//  CoreDataWikipediaPage.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 10/11/2018.
//

import CoreData
import Foundation

final class CoreDataWikipediaPage: NSManagedObject {

    // "language/title"
    @NSManaged var id: String

    @NSManaged var name: String?

    @NSManaged var defaultSort: String?
    @NSManaged var extract: String?

    @NSManaged var wikidataLocalizedEntries: Set<CoreDataWikidataLocalizedEntry>

    override var description: String {
        return (wikipediaId.map { [$0.title, $0.language] } ?? [])
            .joined(separator: " - ")
    }

}
