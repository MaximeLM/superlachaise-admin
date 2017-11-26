//
//  RxOperation.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 08/10/2017.
//

import Foundation
import RxSwift

/**
 Wrap an action in a concurrent operation

 The operation will finish when the result of the action is disposed
 */
class RxOperation: ConcurrentOperation {

    let disposable = CompositeDisposable()

    let action: () -> Disposable

    init(_ action: @escaping () -> Disposable) {
        self.action = action
        super.init()
        _ = disposable.insert(Disposables.create {
            guard !self.isCancelled else {
                return
            }
            self.state = .finished
        })
    }

    override func start() {
        state = .executing
        guard !disposable.isDisposed else {
            return
        }
        _ = disposable.insert(action())
    }

    override func cancel() {
        disposable.dispose()
    }

}
