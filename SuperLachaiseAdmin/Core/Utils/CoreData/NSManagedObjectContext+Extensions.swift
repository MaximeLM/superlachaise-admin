//
//  NSManagedObjectContext+Extensions.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 07/11/2018.
//

import CoreData
import Foundation
import RxSwift

extension NSManagedObjectContext {

    // MARK: Objects

    func objects<Object: NSManagedObject>(_ type: Object.Type) -> Results<Object> {
        return Results(context: self)
    }

    func find<Object: NSManagedObject & KeyedObject>(_ type: Object.Type, key: Object.Key) -> Object? {
        var results = objects(type)
        for (key, value) in type.attributes(key: key) {
            results = results.filtered(by: "%K == %@", [key, value])
        }
        return results.fetch().first
    }

    func findOrCreate<Object: NSManagedObject & KeyedObject>(_ type: Object.Type, key: Object.Key) -> Object {
        if let object = find(type, key: key) {
            return object
        } else {
            let object = Object(context: self)
            for (key, value) in type.attributes(key: key) {
                object.setValue(value, forKey: key)
            }
            return object
        }
    }

    // MARK: Transactions

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