//
//  CommonsFile+Protocols.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 02/03/2018.
//

import Foundation
import RealmSwift

extension CommonsFile: Identifiable, Deletable, Listable, OpenableInBrowser, Syncable {

    // MARK: Identifiable

    var identifier: String {
        return commonsId
    }

    // MARK: Deletable

    func delete() {
        realm?.delete(self)
    }

    // MARK: Listable

    static func list(filter: String) -> (Realm) -> Results<CommonsFile> {
        return { realm in
            var results = all()(realm)
                .sorted(by: [
                    SortDescriptor(keyPath: "commonsId"),
                ])
            if !filter.isEmpty {
                let predicate = NSPredicate(format: "commonsId contains[cd] %@", filter)
                results = results.filter(predicate)
            }
            return results
        }
    }

    // MARK: OpenableInBrowser

    var externalURL: URL? {
        return URL(string: "https://commons.wikimedia.org/wiki")?
            .appendingPathComponent("File:\(commonsId)")
    }

    // MARK: Syncable

    func sync(taskController: TaskController) {
        taskController.syncCommonsFile(self)
    }

}
