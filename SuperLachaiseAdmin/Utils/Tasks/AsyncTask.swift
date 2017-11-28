//
//  AsyncTask.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 28/11/2017.
//

import Foundation
import RxSwift

protocol AsyncTask: Task {

    func execute(_ observer: @escaping (CompletableEvent) -> Void) throws -> Disposable

}

extension AsyncTask {

    func asCompletable() -> Completable {
        return Completable.create { observer in
            do {
                return try self.execute(observer)
            } catch {
                observer(.error(error))
                return Disposables.create()
            }
        }
    }

}
