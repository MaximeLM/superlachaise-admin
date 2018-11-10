//
//  CoreDataPointOfInterest+Protocols.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 10/11/2018.
//

import CoreData
import Foundation

extension CoreDataPointOfInterest: KeyedObject {

    typealias Key = String

    static func attributes(key: Key) -> [String: Any] {
        return ["id": key]
    }

}

extension CoreDataPointOfInterest: Identifiable {

    var identifier: String {
        return id
    }

}

extension CoreDataPointOfInterest: CoreDataListable {

    static func list(filter: String, context: NSManagedObjectContext) -> [CoreDataPointOfInterest] {
        var results = context.objects(CoreDataPointOfInterest.self)
        if !filter.isEmpty {
            let predicate = NSPredicate(format: "name contains[cd] %@ OR id contains[cd] %@",
                                        filter, filter)
            results = results.filtered(by: predicate)
        }
        return results.sorted(byKey: "name").sorted(byKey: "id").fetch()
    }

}

extension CoreDataPointOfInterest: Syncable {

    func sync(taskController: TaskController) {
        //taskController.syncCategory(self) // TODO
    }

}
