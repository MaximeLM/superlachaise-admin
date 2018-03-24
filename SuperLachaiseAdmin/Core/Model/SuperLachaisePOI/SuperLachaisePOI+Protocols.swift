//
//  SuperLachaisePOI+Protocols.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 07/12/2017.
//

import Foundation
import RealmSwift

extension SuperLachaisePOI: Identifiable, Deletable, Listable, Syncable {

    // MARK: Identifiable

    var identifier: String {
        return rawSuperLachaiseId
    }

    // MARK: Deletable

    func delete() {
        realm?.delete(self)
    }

    // MARK: Listable

    static func list(filter: String) -> (Realm) -> Results<SuperLachaisePOI> {
        return { realm in
            var results = all()(realm)
                .sorted(by: [
                    SortDescriptor(keyPath: "rawSuperLachaiseId"),
                ])
            if !filter.isEmpty {
                let predicate = NSPredicate(format: "rawSuperLachaiseId contains[cd] %@",
                                            filter, filter)
                results = results.filter(predicate)
            }
            return results
        }
    }

    // MARK: Syncable

    func sync(taskController: TaskController) {
        taskController.syncSuperLachaisePOI(self)
    }

}
