//
//  BackgroundTask.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 26/11/2017.
//

import Foundation
import RxSwift

class BackgroundTask: CustomStringConvertible {

    // MARK: Execution

    func execute(onSuccess: (() -> Void)? = nil, onError: ((Error) -> Void)? = nil) -> Disposable {
        // Override
        return Disposables.create()
    }

    final func asSingle() -> Single<Void> {
        return Single.create { observer in
            self.execute(onSuccess: { observer(.success(Void())) },
                         onError: { observer(.error($0)) })
        }
            .subscribeOn(scheduler) // Start in background
            .do(onNext: { Logger.success("\(self) succeeded") },
                onError: { Logger.error("\(self) failed: \($0)") },
                onSubscribe: { Logger.info("\(self) started") })
    }

    // MARK: Background schedulers

    final lazy var dispatchQueue: DispatchQueue = { [unowned self] in
        DispatchQueue(label: "\(self)")
    }()

    final lazy var scheduler: ImmediateSchedulerType = { [unowned self] in
        SerialDispatchQueueScheduler(queue: dispatchQueue,
                                     internalSerialQueueName: "\(self).internal")
    }()

    // MARK: CustomStringConvertible

    var description: String {
        return String(describing: type(of: self))
    }

}
