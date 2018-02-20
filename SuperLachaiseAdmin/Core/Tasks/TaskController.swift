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
    let realmContext: RealmContext

    init(config: Config, realmContext: RealmContext) {
        self.config = config
        self.realmContext = realmContext

        self.operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 1

        let runningTasks = self.runningTasks
        self.observation = operationQueue.observe(\OperationQueue.operations) { operationQueue, _ in
            DispatchQueue.main.async {
                runningTasks.accept(operationQueue.operations.flatMap { $0 as? TaskOperation })
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

    let runningTasks = BehaviorRelay<[TaskOperation]>(value: [])

    func enqueue(_ task: Task) {
        operationQueue.addOperation(TaskOperation(task: task))
    }

}
