//
//  Entry+Protocols.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 25/03/2018.
//

import Foundation
import RealmSwift

extension Entry: Identifiable, Deletable, Listable, Syncable {

    // MARK: Identifiable

    var identifier: String {
        return wikidataId
    }

    // MARK: Deletable

    func delete() {
        realm?.delete(localizations)
        realm?.delete(self)
    }

    static func deleted() -> (Realm) -> Results<Entry> {
        return { realm in
            realm.objects(Entry.self).filter("isDeleted == true")
        }
    }

    // MARK: Listable

    static func list(filter: String) -> (Realm) -> Results<Entry> {
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

    // MARK: Syncable

    func sync(taskController: TaskController) {
        if let pointOfInterest = mainEntryOf.first {
            taskController.syncSuperLachaiseObject(pointOfInterest: pointOfInterest)
        } else if let pointOfInterest = secondayEntryOf.first {
            taskController.syncSuperLachaiseObject(pointOfInterest: pointOfInterest)
        } else {
            Logger.info("\(Entry.self) \(self) has no point of interest")
        }
    }

}
