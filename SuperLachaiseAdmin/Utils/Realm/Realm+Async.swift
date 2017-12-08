//
//  Realm+Async.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 08/12/2017.
//

import Foundation
import RealmSwift
import RxSwift

extension Realm {

    /**
     Execute a method with a realm for a dispatch queue
     */
    static func async<E>(configuration: Realm.Configuration = .defaultConfiguration,
                         dispatchQueue: DispatchQueue = DispatchQueue(label: "Realm.async"),
                         task: @escaping (Realm) throws -> E) -> Single<E> {
        return Single.create { observer in
            let cancel = SingleAssignmentDisposable()

            dispatchQueue.async {
                autoreleasepool {
                    guard !cancel.isDisposed else {
                        return
                    }
                    do {
                        let realm = try Realm(configuration: configuration)
                        let result = try task(realm)
                        observer(.success(result))
                    } catch {
                        observer(.error(error))
                    }
                }
            }

            return cancel
        }
    }

}
