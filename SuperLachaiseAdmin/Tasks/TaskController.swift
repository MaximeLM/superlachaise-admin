//
//  TaskController.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 29/11/2017.
//

import Foundation

final class TaskController {

    let config: Config
    let realmContext: RealmContext

    let overpassAPIEndpoint: APIEndpointType

    init(config: Config,
         realmContext: RealmContext,
         overpassAPIEndpoint: APIEndpointType = APIEndpoint.overpass) {
        self.config = config
        self.realmContext = realmContext
        self.operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 1

        self.overpassAPIEndpoint = overpassAPIEndpoint
    }

    // MARK: Tasks

    private let operationQueue: OperationQueue

    func enqueue(_ task: Task) {
        _ = task.asCompletable()
            .enqueue(in: operationQueue)
            .do(onSubscribe: { Logger.info("\(task) started") })
            .subscribe(onError: { Logger.error("\(task) failed: \($0)") },
                       onCompleted: { Logger.success("\(task) succeeded") })
    }

}
