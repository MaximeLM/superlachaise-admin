//
//  CoreDataDatabase.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 07/11/2018.
//

import CoreData
import Foundation
import RxCocoa
import RxSwift

final class CoreDataDatabase {

    init(name: String) {
        let persistentContainer = NSPersistentContainer(name: name)
        persistentContainer.loadPersistentStores { description, error in
            if let error = error {
                fatalError("\(error)")
            }
            Logger.info("database initialized at \(description.url?.path ?? "nil")")
            self.persistentContainerSubject.accept(persistentContainer)
        }
    }

    // MARK: Contexts

    var viewContext: Single<NSManagedObjectContext> {
        return persistentContainer.map({ $0.viewContext })
    }

    func newBackgroundContext() -> Single<NSManagedObjectContext> {
        return persistentContainer.map({ $0.newBackgroundContext() })
    }

    // MARK: Private

    private let persistentContainerSubject = BehaviorRelay<NSPersistentContainer?>(value: nil)

    private var persistentContainer: Single<NSPersistentContainer> {
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
