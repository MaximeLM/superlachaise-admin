//
//  OpenStreetMapElement+Protocols.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 07/11/2018.
//

import CoreData
import Foundation

extension OpenStreetMapElement: KeyedObject {

    typealias Key = OpenStreetMapId

    static func attributes(key: Key) -> [String: Any] {
        return ["id": key.rawValue]
    }

}

extension OpenStreetMapElement: Identifiable {

    var identifier: String {
        return id
    }

}

extension OpenStreetMapElement: Listable {

    static func list(filter: String, context: NSManagedObjectContext) -> [OpenStreetMapElement] {
        var results = context.objects(OpenStreetMapElement.self)
        if !filter.isEmpty {
            let predicate = NSPredicate(format: "name contains[cd] %@ OR id contains[cd] %@",
                                        filter, filter)
            results = results.filtered(by: predicate)
        }
        return results.sorted(byKey: "name").sorted(byKey: "id").fetch()
    }

}

extension OpenStreetMapElement: OpenableInBrowser {

    var externalURL: URL? {
        guard let openStreetMapId = openStreetMapId else {
            return nil
        }
        return URL(string: "https://www.openstreetmap.org")?
            .appendingPathComponent(openStreetMapId.elementType.rawValue)
            .appendingPathComponent("\(openStreetMapId.numericId)")
    }

}

extension OpenStreetMapElement: Syncable {

    func sync(taskController: TaskController) {
        taskController.syncOpenStreetMapElement(self)
    }

}
