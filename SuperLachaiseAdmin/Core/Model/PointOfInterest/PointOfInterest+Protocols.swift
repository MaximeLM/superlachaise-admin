//
//  PointOfInterest+Protocols.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 10/11/2018.
//

import CoreData
import Foundation

extension PointOfInterest: KeyedObject {

    typealias Key = String

    static func attributes(key: Key) -> [String: Any] {
        return ["id": key]
    }

}

extension PointOfInterest: Identifiable {

    var identifier: String {
        return id
    }

}

extension PointOfInterest: Listable {

    static func list(filter: String, context: NSManagedObjectContext) -> [PointOfInterest] {
        var results = context.objects(PointOfInterest.self)
        if !filter.isEmpty {
            let predicate = NSPredicate(format: "name contains[cd] %@ OR id contains[cd] %@",
                                        filter, filter)
            results = results.filtered(by: predicate)
        }
        return results.sorted(byKey: "name").sorted(byKey: "id").fetch()
    }

}

extension PointOfInterest: Syncable {

    func sync(taskController: TaskController) {
        taskController.syncSuperLachaiseObject(pointOfInterest: self)
    }

}
