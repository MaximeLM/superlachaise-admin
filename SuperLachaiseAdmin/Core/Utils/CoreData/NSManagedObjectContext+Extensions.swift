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

extension Reactive where Base: NSManagedObjectContext {

    var didSave: Observable<NSManagedObjectContext> {
        return Observable.create { observer in
            NSManagedObjectContextDidSaveObserver(context: self.base, observer: observer.on)
        }
    }

    func perform() -> Single<NSManagedObjectContext> {
        return Single.create { observer in
            self.base.perform {
                observer(.success(self.base))
            }
            return Disposables.create()
        }
    }

}

private final class NSManagedObjectContextDidSaveObserver: NSObject, Disposable {

    let observer: (Event<NSManagedObjectContext>) -> Void
    let context: NSManagedObjectContext

    init(context: NSManagedObjectContext, observer: @escaping (Event<NSManagedObjectContext>) -> Void) {
        self.context = context
        self.observer = observer
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(contextDidSave(_:)),
                                               name: .NSManagedObjectContextDidSave, object: context)
    }

    @objc
    private func contextDidSave(_ notification: Notification) {
        observer(.next((context)))
    }

    func dispose() {
        NotificationCenter.default.removeObserver(self, name: .NSManagedObjectContextDidSave, object: context)
    }

}
