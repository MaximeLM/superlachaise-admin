//
//  DatabaseV1Mapping+Protocols.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 10/11/2018.
//

import CoreData
import Foundation

extension DatabaseV1Mapping: KeyedObject {

    typealias Key = Int32

    static func attributes(key: Key) -> [String: Any] {
        return ["id": key]
    }

}

extension DatabaseV1Mapping: Identifiable {

    var identifier: String {
        return "\(id)"
    }

}

extension DatabaseV1Mapping: Listable {

    static func list(filter: String, context: NSManagedObjectContext) -> [DatabaseV1Mapping] {
        var results = context.objects(DatabaseV1Mapping.self)
        if !filter.isEmpty {
            let predicate = NSPredicate(
                format: "pointOfInterest.name contains[cd] %@ OR pointOfInterest.id contains[cd] %@",
                filter, filter)
            results = results.filtered(by: predicate)
        }
        return results.sorted(byKey: "id").fetch()
    }

}

extension DatabaseV1Mapping: Syncable {

    func sync(taskController: TaskController) {
        taskController.syncDatabaseV1Mapping(self)
    }

}
