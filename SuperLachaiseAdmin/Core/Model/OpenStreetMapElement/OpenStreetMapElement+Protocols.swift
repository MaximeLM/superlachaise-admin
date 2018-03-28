//
//  OpenStreetMapElement+Protocols.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 07/12/2017.
//

import Foundation
import RealmSwift

extension OpenStreetMapElement: Identifiable, Deletable, Listable, OpenableInBrowser, Syncable {

    // MARK: Identifiable

    var identifier: String {
        return rawOpenStreetMapId
    }

    // MARK: Deletable

    func delete() {
        realm?.delete(self)
    }

    static func deleted() -> (Realm) -> Results<OpenStreetMapElement> {
        return { realm in
            realm.objects(OpenStreetMapElement.self).filter("isDeleted == true")
        }
    }

    // MARK: Listable

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

    // MARK: OpenableInBrowser

    var externalURL: URL? {
        return URL(string: "https://www.openstreetmap.org")?
            .appendingPathComponent(rawOpenStreetMapId)
    }

    // MARK: Syncable

    func sync(taskController: TaskController) {
        taskController.syncOpenStreetMapElement(self)
    }

}
