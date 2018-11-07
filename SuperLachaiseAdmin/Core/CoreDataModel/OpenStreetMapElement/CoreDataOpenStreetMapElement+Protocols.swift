//
//  CoreDataOpenStreetMapElement+Protocols.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 07/11/2018.
//

import CoreData
import Foundation

extension CoreDataOpenStreetMapElement: KeyedObject {

    typealias Key = OpenStreetMapId

    static func attributes(key: Key) -> [String: Any] {
        return ["id": key.rawValue]
    }

}

extension CoreDataOpenStreetMapElement: Identifiable {

    var identifier: String {
        return id
    }

}

extension CoreDataOpenStreetMapElement: CoreDataListable {

    static func list(filter: String, context: NSManagedObjectContext) -> [CoreDataOpenStreetMapElement] {
        var results = context.objects(CoreDataOpenStreetMapElement.self)
        if !filter.isEmpty {
            let predicate = NSPredicate(format: "name contains[cd] %@ OR id contains[cd] %@",
                                        filter, filter)
            results = results.filtered(by: predicate)
        }
        return results.sorted(byKey: "name").sorted(byKey: "id").fetch()
    }

}
