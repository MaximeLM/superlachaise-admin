//
//  Operation+Rx.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 26/11/2017.
//

import Foundation
import RxSwift

extension ObservableConvertibleType {

    /**
     Subscribe the observable in a concurrent operation.
     The operation will finish when the sequence is disposed.
    */
    func enqueue(in operationQueue: OperationQueue) -> Observable<E> {
        return Observable.create { observer in
            let operation = ObservableOperation(observable: self.asObservable(), observer: observer.on)
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

/**
 Wraps a subscription in a concurrent operation
 The operation starts by subscribing to its observable and finishes when the subscription is disposed
 */
class ObservableOperation<E>: ConcurrentOperation {

    let observable: Observable<E>
    let observer: ((Event<E>) -> Void)

    init(observable: Observable<E>, observer: @escaping ((Event<E>) -> Void)) {
        self.observable = observable
        self.observer = observer
    }

    // MARK: Operation

    private var subscription: Disposable?

    override func start() {
        state = .executing

        guard !isCancelled else {
            state = .finished
            return
        }

        subscription = observable
            .do(onDispose: {
                self.state = .finished
            })
            .subscribe(self.observer)

    }

    override func cancel() {
        super.cancel()
        subscription?.dispose()
    }

}
