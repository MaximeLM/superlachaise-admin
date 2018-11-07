//
//  NSManagedObjectContext+Extensions.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 07/11/2018.
//

import CoreData
import Foundation

extension NSManagedObjectContext {

    func objects<Object: NSManagedObject>(_ type: Object.Type) -> CoreDataResults<Object> {
        return CoreDataResults(context: self)
    }

    func find<Key: CoreDataObjectKey>(_ type: Key.CoreDataObject.Type, key: Key) -> Key.CoreDataObject? {
        var results = objects(type)
        for (key, value) in key.coreDataAttributes {
            results = results.filtered(by: "%K == %@", [key, value])
        }
        return results.fetch().first
    }

    func findOrCreate<Key: CoreDataObjectKey>(_ type: Key.CoreDataObject.Type, key: Key) -> Key.CoreDataObject {
        if let object = find(type, key: key) {
            return object
        } else {
            let object = Key.CoreDataObject(context: self)
            for (key, value) in key.coreDataAttributes {
                object.setValue(value, forKey: key)
            }
            return object
        }
    }

    func write<T>(_ block: (() throws -> T)) throws -> T {
        let result: T
        do {
            result = try block()
        } catch {
            rollback()
            throw error
        }
        try save()
        return result
    }

}
