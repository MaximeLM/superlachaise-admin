//
//  Database.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 07/11/2018.
//

import CoreData
import Foundation
import RxCocoa
import RxSwift

final class Database {

    init(name: String) {
        let persistentContainer = NSPersistentContainer(name: name)
        persistentContainer.loadPersistentStores { description, error in
            if let error = error {
                fatalError("\(error)")
            }
            Logger.info("database initialized at \(description.url?.path ?? "nil")")
            persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
            self.persistentContainerSubject.accept(persistentContainer)
        }
    }

    // MARK: Contexts

    var contextDidSave: Observable<Void> {
        return Observable.create { observer in
            NSManagedObjectContextDidSaveObserver(observer: observer.on)
        }
            .observeOn(MainScheduler.asyncInstance)
    }

    var performInViewContext: Single<NSManagedObjectContext> {
        return persistentContainer.flatMap { persistentContainer in
            Single.create { observer in
                let context = persistentContainer.viewContext
                context.perform {
                    observer(.success(context))
                }
                return Disposables.create()
            }
        }
    }

    var performInBackground: Single<NSManagedObjectContext> {
        return persistentContainer.flatMap { persistentContainer in
            Single.create { observer in
                persistentContainer.performBackgroundTask { context in
                    observer(.success(context))
                }
                return Disposables.create()
            }
        }
    }

    // MARK: Private

    private let persistentContainerSubject = BehaviorRelay<NSPersistentContainer?>(value: nil)

    private var persistentContainer: Single<NSPersistentContainer> {
        if let persistentContainer = self.persistentContainerSubject.value {
            return Single.just(persistentContainer)
        }
        return Single.create { observer in
            var didFinish = false
            return self.persistentContainerSubject.subscribe(onNext: { persistentContainer in
                if !didFinish, let persistentContainer = persistentContainer {
                    didFinish = true
                    observer(.success(persistentContainer))
                }
            })
        }
    }

}

private final class NSManagedObjectContextDidSaveObserver: NSObject, Disposable {

    let observer: (Event<Void>) -> Void

    init(observer: @escaping (Event<Void>) -> Void) {
        self.observer = observer
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(contextDidSave(_:)),
                                               name: .NSManagedObjectContextDidSave, object: nil)
    }

    @objc
    private func contextDidSave(_ notification: Notification) {
        observer(.next(()))
    }

    func dispose() {
        NotificationCenter.default.removeObserver(self, name: .NSManagedObjectContextDidSave, object: nil)
    }

}
