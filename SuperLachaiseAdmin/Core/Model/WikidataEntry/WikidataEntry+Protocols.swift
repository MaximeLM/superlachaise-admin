//
//  WikidataEntry+Protocols.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 07/11/2018.
//

import CoreData
import Foundation

extension WikidataEntry: KeyedObject {

    typealias Key = String

    static func attributes(key: Key) -> [String: Any] {
        return ["id": key]
    }

}

extension WikidataEntry: Identifiable {

    var identifier: String {
        return id
    }

}

extension WikidataEntry: Listable {

    static func list(filter: String, context: NSManagedObjectContext) -> [WikidataEntry] {
        var results = context.objects(WikidataEntry.self)
        if !filter.isEmpty {
            let predicate = NSPredicate(format: "name contains[cd] %@ OR id contains[cd] %@",
                                        filter, filter)
            results = results.filtered(by: predicate)
        }
        return results.sorted(byKey: "name").sorted(byKey: "id").fetch()
    }

}

extension WikidataEntry: OpenableInBrowser {

    var externalURL: URL? {
        return URL(string: "https://www.wikidata.org/wiki")?
            .appendingPathComponent(id)
    }

}

extension WikidataEntry: Syncable {

    func sync(taskController: TaskController) {
        taskController.syncWikidataEntry(self)
    }

}
