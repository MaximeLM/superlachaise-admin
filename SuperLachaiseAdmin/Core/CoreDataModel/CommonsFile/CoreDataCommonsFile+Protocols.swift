//
//  CoreDataCommonsFile+Protocols.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 10/11/2018.
//

import CoreData
import Foundation

extension CoreDataCommonsFile: KeyedObject {

    typealias Key = String

    static func attributes(key: Key) -> [String: Any] {
        return ["id": key]
    }

}

extension CoreDataCommonsFile: Identifiable {

    var identifier: String {
        return id
    }

}

extension CoreDataCommonsFile: CoreDataListable {

    static func list(filter: String, context: NSManagedObjectContext) -> [CoreDataCommonsFile] {
        var results = context.objects(CoreDataCommonsFile.self)
        if !filter.isEmpty {
            let predicate = NSPredicate(format: "id contains[cd] %@", filter)
            results = results.filtered(by: predicate)
        }
        return results.sorted(byKey: "id").fetch()
    }

}

extension CoreDataCommonsFile: OpenableInBrowser {

    var externalURL: URL? {
        return URL(string: "https://commons.wikimedia.org/wiki")?
            .appendingPathComponent("File:\(id)")
    }

}

extension CoreDataCommonsFile: Syncable {

    func sync(taskController: TaskController) {
        taskController.syncCommonsFile(self)
    }

}
