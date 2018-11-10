//
//  CoreDataWikipediaPage+Protocols.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 10/11/2018.
//

import CoreData
import Foundation

extension CoreDataWikipediaPage: KeyedObject {

    typealias Key = WikipediaId

    static func attributes(key: Key) -> [String: Any] {
        return ["id": key.rawValue]
    }

}

extension CoreDataWikipediaPage: Identifiable {

    var identifier: String {
        return id
    }

}

extension CoreDataWikipediaPage: CoreDataListable {

    static func list(filter: String, context: NSManagedObjectContext) -> [CoreDataWikipediaPage] {
        var results = context.objects(CoreDataWikipediaPage.self)
        if !filter.isEmpty {
            let predicate = NSPredicate(format: "name contains[cd]", filter)
            results = results.filtered(by: predicate)
        }
        return results.sorted(byKey: "defaultSort").sorted(byKey: "name").sorted(byKey: "id").fetch()
    }

}

extension CoreDataWikipediaPage: OpenableInBrowser {

    var externalURL: URL? {
        guard let wikipediaId = wikipediaId else {
            return nil
        }
        return URL(string: "https://\(wikipediaId.language).wikipedia.org/wiki")?
            .appendingPathComponent(wikipediaId.title)
    }

}
