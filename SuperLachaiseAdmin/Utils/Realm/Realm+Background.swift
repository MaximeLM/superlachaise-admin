//
//  Realm+Background.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 28/11/2017.
//

import Foundation
import RealmSwift
import RxSwift

extension Realm {

    static func background(dispatchQueue: DispatchQueue = DispatchQueue(label: "Realm.background")) -> Single<Realm> {
        return Single.create { observer in
            let cancel = SingleAssignmentDisposable()

            dispatchQueue.async {
                autoreleasepool {
                    guard !cancel.isDisposed else {
                        return
                    }
                    do {
                        let realm = try Realm()
                        observer(.success(realm))
                    } catch {
                        observer(.error(error))
                    }
                }
            }

            return cancel
        }
    }

    static func background<I, O>(dispatchQueue: DispatchQueue = DispatchQueue(label: "Realm.background"),
                                 _ task: @escaping (I, Realm) throws -> O) -> (I) -> Single<O> {
        return { input in
            return background(dispatchQueue: dispatchQueue)
                .map { realm in
                    try task(input, realm)
                }
        }
    }

}
