//
//  CoreDataCategory+Protocols.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 10/11/2018.
//

import CoreData
import Foundation

extension CoreDataCategory: KeyedObject {

    typealias Key = String

    static func attributes(key: Key) -> [String: Any] {
        return ["id": key]
    }

}

extension CoreDataCategory: Identifiable {

    var identifier: String {
        return id
    }

}

extension CoreDataCategory: CoreDataListable {

    static func list(filter: String, context: NSManagedObjectContext) -> [CoreDataCategory] {
        var results = context.objects(CoreDataCategory.self)
        if !filter.isEmpty {
            let predicate = NSPredicate(format: "id contains[cd] %@", filter)
            results = results.filtered(by: predicate)
        }
        return results.sorted(byKey: "id").fetch()
    }

}
