//
//  DatabaseV1Mapping+Protocols.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 30/03/2018.
//

import Foundation
import RealmSwift

extension DatabaseV1Mapping: Identifiable, Deletable, Listable, Syncable {

    // MARK: Identifiable

    var identifier: String {
        return "\(monumentId)"
    }

    // MARK: Deletable

    func delete() {
        realm?.delete(self)
    }

    static func deleted() -> (Realm) -> Results<DatabaseV1Mapping> {
        return { realm in
            realm.objects(DatabaseV1Mapping.self).filter("isDeleted == true")
        }
    }

    // MARK: Listable

    static func list(filter: String) -> (Realm) -> Results<DatabaseV1Mapping> {
        return { realm in
            var results = all()(realm)
                .sorted(by: [
                    SortDescriptor(keyPath: "monumentId"),
                ])
            if !filter.isEmpty {
                let predicate = NSPredicate(
                    format: "pointOfInterest.name contains[cd] %@ OR pointOfInterest.id contains[cd] %@",
                    filter, filter)
                results = results.filter(predicate)
            }
            return results
        }
    }

    // MARK: Syncable

    func sync(taskController: TaskController) {
        taskController.syncDatabaseV1Mapping(self)
    }

}
