//
//  Operation+Rx.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 26/11/2017.
//

import Foundation
import RxSwift

extension Observable {

    /**
     Subscribe the observable in a concurrent operation.

     The operation will finish when the sequence is disposed.
    */
    final func enqueue(in operationQueue: OperationQueue) -> Observable<E> {
        return Observable.create { observer in
            let operation = RxOperation { self.subscribe(observer) }
            operationQueue.addOperation(operation)
            return operation
        }
    }

}

extension Operation: Disposable {

    public func dispose() {
        cancel()
    }

}
