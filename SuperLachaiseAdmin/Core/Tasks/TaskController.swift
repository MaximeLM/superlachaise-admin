//
//  TaskController.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 29/11/2017.
//

import Foundation
import RxCocoa
import RxSwift

final class TaskController {

    let config: Config
    let database: CoreDataDatabase

    init(config: Config, database: CoreDataDatabase) {
        self.config = config
        self.database = database

        self.operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 1

        let runningTasks = self.runningTasks
        self.observation = operationQueue.observe(\OperationQueue.operations) { operationQueue, _ in
            DispatchQueue.main.async {
                runningTasks.accept(operationQueue.operations)
            }
        }
    }

    // MARK: API endpoints

    lazy var overpassAPIEndpoint: APIEndpointType = APIEndpoint.overpass
    lazy var wikidataAPIEndpoint: APIEndpointType = APIEndpoint.wikidata
    lazy var wikipediaAPIEndpoint: (String) -> APIEndpointType = { APIEndpoint.wikipedia(language: $0) }
    lazy var commonsAPIEndpoint: APIEndpointType = APIEndpoint.commons

    // MARK: Tasks

    private let operationQueue: OperationQueue

    private var observation: NSKeyValueObservation?

    let runningTasks = BehaviorRelay<[Operation]>(value: [])

    func enqueue(_ task: Task) {
        operationQueue.addOperation(TaskOperation(task: task))
    }

    func enqueue(_ task: CoreDataTask) {
        operationQueue.addOperation(CoreDataTaskOperation(task: task, database: database))
    }

}
