//
//  SyncTask.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 28/11/2017.
//

import Foundation
import RxSwift

protocol SyncTask: Task {

    func execute() throws

}

extension SyncTask {

    func asCompletable() -> Completable {
        return Completable.create { observer in
            do {
                try self.execute()
                observer(.completed)
            } catch {
                observer(.error(error))
            }
            return Disposables.create()
        }
    }

}
