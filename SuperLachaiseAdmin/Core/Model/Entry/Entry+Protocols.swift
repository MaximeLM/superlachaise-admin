//
//  Entry+Protocols.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 25/03/2018.
//

import Foundation
import RealmSwift

extension Entry: Identifiable, Deletable, Listable {

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

    static func list(filter: String) -> (Realm) -> Results<Entry> {
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

}
