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

    let operationQueue: OperationQueue

    let overpassAPIEndpoint: APIEndpointType

    init(config: Config,
         realmContext: RealmContext,
         overpassAPIEndpoint: APIEndpointType = APIEndpoint.overpass) {
        self.config = config
        self.realmContext = realmContext
        self.operationQueue = OperationQueue()

        self.overpassAPIEndpoint = overpassAPIEndpoint
    }

}
