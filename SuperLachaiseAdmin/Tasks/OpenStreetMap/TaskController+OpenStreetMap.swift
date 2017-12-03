//
//  TaskController+OpenStreetMap.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 29/11/2017.
//

import Foundation

extension TaskController {

    func syncOpenStreetMapElements() {
        let scope: SyncOpenStreetMapElements.Scope = .all(
            boundingBox: config.openStreetMap.boundingBox,
            fetchedTags: config.openStreetMap.fetchedTags)
        let task = SyncOpenStreetMapElements(scope: scope,
                                             realmContext: realmContext,
                                             endpoint: overpassAPIEndpoint)
        operationQueue.addOperation(task.asOperation())
    }

    func syncOpenStreetMapElements(_ openStreetMapElements: [OpenStreetMapElement]) {
        let openStreetMapIds = openStreetMapElements.flatMap { $0.openStreetMapId }
        let scope: SyncOpenStreetMapElements.Scope = .list(openStreetMapIds)
        let task = SyncOpenStreetMapElements(scope: scope,
                                             realmContext: realmContext,
                                             endpoint: overpassAPIEndpoint)
        operationQueue.addOperation(task.asOperation())
    }

}