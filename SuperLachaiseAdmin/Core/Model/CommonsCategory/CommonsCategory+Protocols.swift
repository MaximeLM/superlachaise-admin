//
//  CommonsCategory+Protocols.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 20/02/2018.
//

import Foundation
import RealmSwift

extension CommonsCategory: Identifiable, Deletable, Listable, OpenableInBrowser, Syncable {

    // MARK: Identifiable

    var identifier: String {
        return commonsCategoryId
    }

    // MARK: Deletable

    func delete() {
        realm?.delete(self)
    }

    // MARK: Listable

    static func list(filter: String) -> (Realm) -> Results<CommonsCategory> {
        return { realm in
            var results = all()(realm)
                .sorted(by: [
                    SortDescriptor(keyPath: "commonsCategoryId"),
                ])
            if !filter.isEmpty {
                let predicate = NSPredicate(format: "commonsCategoryId contains[cd] %@", filter)
                results = results.filter(predicate)
            }
            return results
        }
    }

    // MARK: OpenableInBrowser

    var externalURL: URL? {
        guard let commonsCategoryId = commonsCategoryId
            .addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
                return nil
        }
        return URL(string: "https://commons.wikimedia.org/wiki")?
            .appendingPathComponent("Category:\(commonsCategoryId)")
    }

    // MARK: Syncable

    func sync(taskController: TaskController) {
        taskController.syncCommonsCategory(self)
    }

}
