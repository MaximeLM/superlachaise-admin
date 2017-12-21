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

    init(config: Config, realmContext: RealmContext) {
        self.config = config
        self.realmContext = realmContext
        self.operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 1
    }

    // MARK: API endpoints

    lazy var overpassAPIEndpoint: APIEndpointType = APIEndpoint.overpass
    lazy var wikidataAPIEndpoint: APIEndpointType = APIEndpoint.wikidata
    lazy var wikipediaAPIEndpoint: (String) -> APIEndpointType = { APIEndpoint.wikipedia(language: $0) }

    // MARK: Tasks

    private let operationQueue: OperationQueue

    func enqueue(_ task: Task) {
        _ = task.asSingle()
            .enqueue(in: operationQueue)
            .do(onSubscribe: { Logger.info("\(task) started") })
            .subscribe(onError: { Logger.error("\(task) failed: \($0)") },
                       onCompleted: { Logger.success("\(task) succeeded") })
    }

}
