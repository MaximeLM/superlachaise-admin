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
    static func async<T>(dispatchQueue: DispatchQueue,
                         configuration: Realm.Configuration = .defaultConfiguration,
                         task: @escaping (Realm) throws -> T) -> Single<T> {
        return Single.create { observer in
            let cancel = SingleAssignmentDisposable()

            dispatchQueue.async {
                guard !cancel.isDisposed else {
                    return
                }
                do {
                    try autoreleasepool {
                        let realm = try Realm(configuration: configuration)
                        let result = try task(realm)
                        observer(.success(result))
                    }
                } catch {
                    observer(.error(error))
                }
            }

            return cancel
        }
    }

}
