//
//  WikipediaPage+Protocols.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 10/11/2018.
//

import CoreData
import Foundation

extension WikipediaPage: KeyedObject {

    typealias Key = WikipediaId

    static func attributes(key: Key) -> [String: Any] {
        return ["id": key.rawValue]
    }

}

extension WikipediaPage: Identifiable {

    var identifier: String {
        return id
    }

}

extension WikipediaPage: Listable {

    static func list(filter: String, context: NSManagedObjectContext) -> [WikipediaPage] {
        var results = context.objects(WikipediaPage.self)
        if !filter.isEmpty {
            let predicate = NSPredicate(format: "name contains[cd] %@", filter)
            results = results.filtered(by: predicate)
        }
        return results.sorted(byKey: "defaultSort").sorted(byKey: "name").sorted(byKey: "id").fetch()
    }

}

extension WikipediaPage: OpenableInBrowser {

    var externalURL: URL? {
        guard let wikipediaId = wikipediaId else {
            return nil
        }
        return URL(string: "https://\(wikipediaId.language).wikipedia.org/wiki")?
            .appendingPathComponent(wikipediaId.title)
    }

}

extension WikipediaPage: Syncable {

    func sync(taskController: TaskController) {
        taskController.syncWikipediaPage(self)
    }

}
