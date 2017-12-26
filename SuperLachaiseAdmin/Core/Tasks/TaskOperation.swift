//
//  TaskOperation.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 26/12/2017.
//

import Foundation

final class TaskOperation: ObservableOperation<Void> {

    let task: Task

    init(task: Task) {
        self.task = task
        super.init(observable: task
            .asSingle().asObservable()
            .do(onNext: { _ in Logger.success("\(task) succeeded") },
                onError: { Logger.error("\(task) failed: \($0)") },
                onSubscribe: { Logger.info("\(task) started") })) { _ in }
    }

    override var description: String {
        return task.description
    }

}
