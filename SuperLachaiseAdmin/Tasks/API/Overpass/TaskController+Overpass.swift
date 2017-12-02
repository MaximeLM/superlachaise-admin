//
//  TaskController+Overpass.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 29/11/2017.
//

import Foundation

extension TaskController {

    func fetchOpenStreetMapElements() {
        let scope: FetchOpenStreetMapElements.Scope = .all(
            boundingBox: config.openStreetMap.boundingBox,
            fetchedTags: config.openStreetMap.fetchedTags)
        let task = FetchOpenStreetMapElements(scope: scope,
                                              realmContext: realmContext,
                                              endpoint: overpassAPIEndpoint)
        operationQueue.addOperation(task.asOperation())
    }

    func fetchOpenStreetMapElements(_ openStreetMapElements: [OpenStreetMapElement]) {
        let openStreetMapIds = openStreetMapElements.flatMap { $0.openStreetMapId }
        let scope: FetchOpenStreetMapElements.Scope = .list(openStreetMapIds)
        let task = FetchOpenStreetMapElements(scope: scope,
                                              realmContext: realmContext,
                                              endpoint: overpassAPIEndpoint)
        operationQueue.addOperation(task.asOperation())
    }

}
