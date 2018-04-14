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
        return id
    }

    // MARK: Deletable

    func delete() {
        realm?.delete(self)
    }

    // MARK: Listable

    static func list(filter: String) -> (Realm) -> Results<OpenStreetMapElement> {
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

    // MARK: OpenableInBrowser

    var externalURL: URL? {
        guard let openStreetMapId = openStreetMapId else {
            return nil
        }
        return URL(string: "https://www.openstreetmap.org")?
            .appendingPathComponent(openStreetMapId.elementType.rawValue)
            .appendingPathComponent("\(openStreetMapId.numericId)")
    }

    // MARK: Syncable

    func sync(taskController: TaskController) {
        taskController.syncOpenStreetMapElement(self)
    }

}
