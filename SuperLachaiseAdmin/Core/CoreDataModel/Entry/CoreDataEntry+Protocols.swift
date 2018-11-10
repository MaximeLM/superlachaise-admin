//
//  CoreDataEntry+Protocols.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 10/11/2018.
//

import CoreData
import Foundation

extension CoreDataEntry: KeyedObject {

    typealias Key = String

    static func attributes(key: Key) -> [String: Any] {
        return ["id": key]
    }

}

extension CoreDataEntry: Identifiable {

    var identifier: String {
        return id
    }

}

extension CoreDataEntry: CoreDataListable {

    static func list(filter: String, context: NSManagedObjectContext) -> [CoreDataEntry] {
        var results = context.objects(CoreDataEntry.self)
        if !filter.isEmpty {
            let predicate = NSPredicate(format: "name contains[cd] %@ OR id contains[cd] %@",
                                        filter, filter)
            results = results.filtered(by: predicate)
        }
        return results.sorted(byKey: "name").sorted(byKey: "id").fetch()
    }

}

extension CoreDataEntry: Syncable {

    func sync(taskController: TaskController) {
        if let pointOfInterest = mainEntryOf.first {
            taskController.syncSuperLachaiseObject(pointOfInterest: pointOfInterest)
        } else if let pointOfInterest = secondaryEntryOf.first {
            taskController.syncSuperLachaiseObject(pointOfInterest: pointOfInterest)
        } else {
            Logger.info("\(Entry.self) \(self) has no point of interest")
        }
    }

}
