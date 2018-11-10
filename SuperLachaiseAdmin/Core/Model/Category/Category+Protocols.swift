//
//  Category+Protocols.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 10/11/2018.
//

import CoreData
import Foundation

extension Category: KeyedObject {

    typealias Key = String

    static func attributes(key: Key) -> [String: Any] {
        return ["id": key]
    }

}

extension Category: Identifiable {

    var identifier: String {
        return id
    }

}

extension Category: Listable {

    static func list(filter: String, context: NSManagedObjectContext) -> [Category] {
        var results = context.objects(Category.self)
        if !filter.isEmpty {
            let predicate = NSPredicate(format: "id contains[cd] %@", filter)
            results = results.filtered(by: predicate)
        }
        return results.sorted(byKey: "id").fetch()
    }

}

extension Category: Syncable {

    func sync(taskController: TaskController) {
        taskController.syncCategory(self)
    }

}
