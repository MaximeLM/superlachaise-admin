//
//  CoreDataWikidataCategory+Protocols.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 10/11/2018.
//

import CoreData
import Foundation

extension CoreDataWikidataCategory: KeyedObject {

    typealias Key = String

    static func attributes(key: Key) -> [String: Any] {
        return ["id": key]
    }

}

extension CoreDataWikidataCategory: Identifiable {

    var identifier: String {
        return id
    }

}

extension CoreDataWikidataCategory: CoreDataListable {

    static func list(filter: String, context: NSManagedObjectContext) -> [CoreDataWikidataCategory] {
        var results = context.objects(CoreDataWikidataCategory.self)
        if !filter.isEmpty {
            let predicate = NSPredicate(
                format: "name contains[cd] %@ OR id contains[cd] %@ OR ANY categories.id contains[cd] %@",
                filter, filter, filter)
            results = results.filtered(by: predicate)
        }
        return results.sorted(byKey: "name").sorted(byKey: "id").fetch()
    }

}

extension CoreDataWikidataCategory: OpenableInBrowser {

    var externalURL: URL? {
        return URL(string: "https://www.wikidata.org/wiki")?
            .appendingPathComponent(id)
    }

}
