//
//  WikidataEntry+Protocols.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 10/12/2017.
//

import Foundation
import RealmSwift

extension WikidataEntry: RealmDeletable, RealmListable, RealmOpenableInBrowser {

    // MARK: RealmDeletable

    func delete() {
        realm?.delete(localizations)
        realm?.delete(self)
    }

    // MARK: RealmIdentifiable

    var identifier: String {
        return wikidataId
    }

    // MARK: RealmListable

    static func list(filter: String = "") -> (Realm) -> Results<WikidataEntry> {
        return { realm in
            var results = realm.objects(WikidataEntry.self)
                .filter("toBeDeleted == false")
                .sorted(by: [
                    SortDescriptor(keyPath: "name"),
                    SortDescriptor(keyPath: "wikidataId"),
                ])
            if !filter.isEmpty {
                let predicate = NSPredicate(format: "name contains[cd] %@ OR wikidataId contains[cd] %@",
                                            filter, filter)
                results = results.filter(predicate)
            }
            return results
        }
    }

    // MARK: RealmOpenableInBrowser

    var externalURL: URL? {
        guard let baseURL = URL(string: "https://www.wikidata.org/wiki") else {
                return nil
        }
        return baseURL.appendingPathComponent(wikidataId)
    }

}
