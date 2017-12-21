//
//  OpenStreetMapElement+Protocols.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 07/12/2017.
//

import Foundation
import RealmSwift

extension OpenStreetMapElement: RealmDeletable, RealmListable, RealmOpenableInBrowser {

    // MARK: RealmDeletable

    func delete() {
        realm?.delete(self)
    }

    // MARK: RealmIdentifiable

    var identifier: String {
        return rawOpenStreetMapId
    }

    // MARK: RealmListable

    static func list(filter: String) -> (Realm) -> Results<OpenStreetMapElement> {
        return { realm in
            var results = all()(realm)
                .sorted(by: [
                    SortDescriptor(keyPath: "name"),
                    SortDescriptor(keyPath: "rawOpenStreetMapId"),
                ])
            if !filter.isEmpty {
                let predicate = NSPredicate(format: "name contains[cd] %@ OR rawOpenStreetMapId contains[cd] %@",
                                            filter, filter)
                results = results.filter(predicate)
            }
            return results
        }
    }

    // MARK: RealmOpenableInBrowser

    var externalURL: URL? {
        return URL(string: "https://www.openstreetmap.org/\(rawOpenStreetMapId)")
    }

}
