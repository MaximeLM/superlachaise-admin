//
//  WikidataEntry+Protocols.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 10/12/2017.
//

import Foundation
import RealmSwift

extension WikidataEntry: Identifiable, Deletable, Listable, OpenableInBrowser {

    // MARK: Identifiable

    var identifier: String {
        return id
    }

    // MARK: Deletable

    func delete() {
        realm?.delete(localizations)
        realm?.delete(self)
    }

    // MARK: Listable

    static func list(filter: String) -> (Realm) -> Results<WikidataEntry> {
        return { realm in
            var results = all()(realm)
                .sorted(by: [
                    SortDescriptor(keyPath: "name"),
                    SortDescriptor(keyPath: "id"),
                ])
            if !filter.isEmpty {
                let predicate = NSPredicate(format: "name contains[cd] %@ OR id contains[cd] %@",
                                            filter, filter)
                results = results.filter(predicate)
            }
            return results
        }
    }

    // MARK: OpenableInBrowser

    var externalURL: URL? {
        return URL(string: "https://www.wikidata.org/wiki")?
            .appendingPathComponent(id)
    }

}
