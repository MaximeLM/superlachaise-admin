//
//  CoreDataDatabaseV1Mapping+Protocols.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 10/11/2018.
//

import CoreData
import Foundation

extension CoreDataDatabaseV1Mapping: KeyedObject {

    typealias Key = Int

    static func attributes(key: Key) -> [String: Any] {
        return ["id": key]
    }

}

extension CoreDataDatabaseV1Mapping: Identifiable {

    var identifier: String {
        return "\(id)"
    }

}

extension CoreDataDatabaseV1Mapping: CoreDataListable {

    static func list(filter: String, context: NSManagedObjectContext) -> [CoreDataDatabaseV1Mapping] {
        var results = context.objects(CoreDataDatabaseV1Mapping.self)
        if !filter.isEmpty {
            let predicate = NSPredicate(
                format: "pointOfInterest.name contains[cd] %@ OR pointOfInterest.id contains[cd] %@",
                filter, filter)
            results = results.filtered(by: predicate)
        }
        return results.sorted(byKey: "id").fetch()
    }

}

extension CoreDataDatabaseV1Mapping: Syncable {

    func sync(taskController: TaskController) {
        //taskController.syncSuperLachaiseObject(pointOfInterest: self) // TODO
    }

}
