//
//  TaskController+OpenStreetMap.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 29/11/2017.
//

import Foundation

extension TaskController {

    func syncOpenStreetMapElements() {
        let scope: SyncOpenStreetMapElements.Scope = .all
        let task = SyncOpenStreetMapElements(scope: scope, config: config.openStreetMap, endpoint: overpassAPIEndpoint)
        enqueue(task)
    }

    func syncOpenStreetMapElement(_ openStreetMapElement: OpenStreetMapElement) {
        guard let openStreetMapId = openStreetMapElement.openStreetMapId else {
            return
        }
        let task = SyncOpenStreetMapElements(scope: .single(openStreetMapId: openStreetMapId),
                                             config: config.openStreetMap,
                                             endpoint: overpassAPIEndpoint)
        enqueue(task)
    }

}
