//
//  WikidataCategory+Protocols.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 10/11/2018.
//

import CoreData
import Foundation

extension WikidataCategory: KeyedObject {

    typealias Key = String

    static func attributes(key: Key) -> [String: Any] {
        return ["id": key]
    }

}

extension WikidataCategory: Identifiable {

    var identifier: String {
        return id
    }

}

extension WikidataCategory: Listable {

    static func list(filter: String, context: NSManagedObjectContext) -> [WikidataCategory] {
        var results = context.objects(WikidataCategory.self)
        if !filter.isEmpty {
            let predicate = NSPredicate(
                format: "name contains[cd] %@ OR id contains[cd] %@ OR ANY categories.id contains[cd] %@",
                filter, filter, filter)
            results = results.filtered(by: predicate)
        }
        return results.sorted(byKey: "name").sorted(byKey: "id").fetch()
    }

}

extension WikidataCategory: OpenableInBrowser {

    var externalURL: URL? {
        return URL(string: "https://www.wikidata.org/wiki")?
            .appendingPathComponent(id)
    }

}

extension WikidataCategory: Syncable {

    func sync(taskController: TaskController) {
        taskController.syncWikidataCategory(self)
    }

}
