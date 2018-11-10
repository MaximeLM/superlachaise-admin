//
//  LocalizedCategory.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 10/11/2018.
//

import CoreData
import Foundation

final class LocalizedCategory: NSManagedObject {

    @NSManaged var language: String
    @NSManaged var name: String

    @NSManaged var category: Category?

    override var description: String {
        return [name, language]
            .compactMap { $0 }
            .joined(separator: " - ")
    }

}
