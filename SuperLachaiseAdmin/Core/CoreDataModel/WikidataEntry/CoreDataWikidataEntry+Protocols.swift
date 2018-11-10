//
//  CoreDataWikidataEntry+Protocols.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 07/11/2018.
//

import CoreData
import Foundation

extension CoreDataWikidataEntry: KeyedObject {

    typealias Key = String

    static func attributes(key: Key) -> [String: Any] {
        return ["id": key]
    }

}

extension CoreDataWikidataEntry: Identifiable {

    var identifier: String {
        return id
    }

}

extension CoreDataWikidataEntry: CoreDataListable {

    static func list(filter: String, context: NSManagedObjectContext) -> [CoreDataWikidataEntry] {
        var results = context.objects(CoreDataWikidataEntry.self)
        if !filter.isEmpty {
            let predicate = NSPredicate(format: "name contains[cd] %@ OR id contains[cd] %@",
                                        filter, filter)
            results = results.filtered(by: predicate)
        }
        return results.sorted(byKey: "name").sorted(byKey: "id").fetch()
    }

}

extension CoreDataWikidataEntry: OpenableInBrowser {

    var externalURL: URL? {
        return URL(string: "https://www.wikidata.org/wiki")?
            .appendingPathComponent(id)
    }

}
