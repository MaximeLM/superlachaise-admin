//
//  Observable+Operation.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 26/11/2017.
//

import Foundation
import RxSwift

extension Observable {

    final func enqueue(in operationQueue: OperationQueue) -> Observable<E> {
        return Observable.create { observer in
            let operation = RxOperation { self.subscribe(observer) }
            operationQueue.addOperation(operation)
            return operation.disposable
        }
    }

}
