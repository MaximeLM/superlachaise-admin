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

    func syncOpenStreetMapElement(_ openStreetMapIds: [OpenStreetMapId]) {
        let scope: SyncOpenStreetMapElements.Scope = .list(openStreetMapIds: openStreetMapIds)
        let task = SyncOpenStreetMapElements(scope: scope, config: config.openStreetMap, endpoint: overpassAPIEndpoint)
        enqueue(task)
    }

}
