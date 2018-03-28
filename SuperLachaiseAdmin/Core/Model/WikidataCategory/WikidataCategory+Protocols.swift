//
//  WikidataCategory+Protocols.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 03/03/2018.
//

import Foundation
import RealmSwift

extension WikidataCategory: Identifiable, Deletable, Listable, OpenableInBrowser, Syncable {

    // MARK: Identifiable

    var identifier: String {
        return wikidataId
    }

    // MARK: Deletable

    func delete() {
        realm?.delete(self)
    }

    static func deleted() -> (Realm) -> Results<WikidataCategory> {
        return { realm in
            realm.objects(WikidataCategory.self).filter("isDeleted == true")
        }
    }

    // MARK: Listable

    static func list(filter: String) -> (Realm) -> Results<WikidataCategory> {
        return { realm in
            var results = all()(realm)
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

    // MARK: OpenableInBrowser

    var externalURL: URL? {
        return URL(string: "https://www.wikidata.org/wiki")?
            .appendingPathComponent(wikidataId)
    }

    // MARK: Syncable

    func sync(taskController: TaskController) {
        taskController.syncWikidataCategory(self)
    }

}
