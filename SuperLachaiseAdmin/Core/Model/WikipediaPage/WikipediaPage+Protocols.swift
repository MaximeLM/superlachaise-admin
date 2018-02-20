//
//  WikipediaPage+Protocols.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 21/12/2017.
//

import Foundation
import RealmSwift

extension WikipediaPage: Identifiable, Deletable, Listable, OpenableInBrowser, Syncable {

    // MARK: Identifiable

    var identifier: String {
        return rawWikipediaId
    }

    // MARK: Deletable

    func delete() {
        realm?.delete(self)
    }

    // MARK: Listable

    static func list(filter: String) -> (Realm) -> Results<WikipediaPage> {
        return { realm in
            var results = all()(realm)
                .sorted(by: [
                    SortDescriptor(keyPath: "name"),
                    SortDescriptor(keyPath: "rawWikipediaId"),
                ])
            if !filter.isEmpty {
                let predicate = NSPredicate(format: "name contains[cd] %@", filter)
                results = results.filter(predicate)
            }
            return results
        }
    }

    // MARK: OpenableInBrowser

    var externalURL: URL? {
        guard let wikipediaId = wikipediaId else {
            return nil
        }
        return URL(string: "https://\(wikipediaId.language).wikipedia.org/wiki")?
            .appendingPathComponent(wikipediaId.title)
    }

    // MARK: Syncable

    func sync(taskController: TaskController) {
        taskController.syncWikipediaPage(self)
    }

}
