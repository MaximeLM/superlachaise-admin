//
//  WikipediaPage+Protocols.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 21/12/2017.
//

import Foundation
import RealmSwift

extension WikipediaPage: RealmDeletable, RealmListable, RealmOpenableInBrowser {

    // MARK: RealmDeletable

    func delete() {
        realm?.delete(self)
    }

    // MARK: RealmIdentifiable

    var identifier: String {
        return rawWikipediaId
    }

    // MARK: RealmListable

    static func list(filter: String) -> (Realm) -> Results<WikipediaPage> {
        return { realm in
            var results = all()(realm)
                .sorted(by: [
                    SortDescriptor(keyPath: "name"),
                    SortDescriptor(keyPath: "rawWikipediaId"),
                ])
            if !filter.isEmpty {
                let predicate = NSPredicate(format: "name contains[cd] %@ OR rawWikipediaId contains[cd] %@",
                                            filter, filter)
                results = results.filter(predicate)
            }
            return results
        }
    }

    // MARK: RealmOpenableInBrowser

    var externalURL: URL? {
        guard let wikipediaId = wikipediaId else {
            return nil
        }
        return URL(string: "https://\(wikipediaId.language).wikipedia.org/wiki/\(wikipediaId.title)")
    }

}
