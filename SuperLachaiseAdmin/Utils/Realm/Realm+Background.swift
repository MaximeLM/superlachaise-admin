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

    private static let backgroundDispatchQueue = DispatchQueue(label: "Realm.background")

    static func background(configuration: Realm.Configuration = Realm.Configuration.defaultConfiguration,
                           _ task: @escaping (Realm) throws -> Void) -> Completable {
        return Completable.create { observer in
            let cancel = SingleAssignmentDisposable()

            backgroundDispatchQueue.async {
                autoreleasepool {
                    guard !cancel.isDisposed else {
                        return
                    }
                    do {
                        let realm = try Realm()
                        try task(realm)
                        observer(.completed)
                    } catch {
                        observer(.error(error))
                    }
                }
            }

            return cancel
        }
    }

    static func background<O>(configuration: Realm.Configuration = Realm.Configuration.defaultConfiguration,
                              _ task: @escaping (Realm) throws -> O) -> Single<O> {
        return Single.create { observer in
            let cancel = SingleAssignmentDisposable()

            backgroundDispatchQueue.async {
                autoreleasepool {
                    guard !cancel.isDisposed else {
                        return
                    }
                    do {
                        let realm = try Realm()
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
