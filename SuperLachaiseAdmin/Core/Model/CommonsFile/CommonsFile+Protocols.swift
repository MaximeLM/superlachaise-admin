//
//  CommonsFile+Protocols.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 10/11/2018.
//

import CoreData
import Foundation

extension CommonsFile: KeyedObject {

    typealias Key = String

    static func attributes(key: Key) -> [String: Any] {
        return ["id": key]
    }

}

extension CommonsFile: Identifiable {

    var identifier: String {
        return id
    }

}

extension CommonsFile: Listable {

    static func list(filter: String, context: NSManagedObjectContext) -> [CommonsFile] {
        var results = context.objects(CommonsFile.self)
        if !filter.isEmpty {
            let predicate = NSPredicate(format: "id contains[cd] %@", filter)
            results = results.filtered(by: predicate)
        }
        return results.sorted(byKey: "id").fetch()
    }

}

extension CommonsFile: OpenableInBrowser {

    var externalURL: URL? {
        return URL(string: "https://commons.wikimedia.org/wiki")?
            .appendingPathComponent("File:\(id)")
    }

}

extension CommonsFile: Syncable {

    func sync(taskController: TaskController) {
        taskController.syncCommonsFile(self)
    }

}
