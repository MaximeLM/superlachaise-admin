//
//  Category+Protocols.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 28/03/2018.
//

import Foundation
import RealmSwift

extension Category: Identifiable, Deletable, Listable {

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

    static func list(filter: String) -> (Realm) -> Results<Category> {
        return { realm in
            var results = all()(realm)
                .sorted(by: [
                    SortDescriptor(keyPath: "id"),
                ])
            if !filter.isEmpty {
                let predicate = NSPredicate(format: "id contains[cd] %@", filter)
                results = results.filter(predicate)
            }
            return results
        }
    }

}
