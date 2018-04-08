//
//  TaskController+SuperLachaise.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 24/03/2018.
//

import Foundation

extension TaskController {

    func syncCategories() {
        let task = SyncCategories(scope: .all, config: config.superLachaise)
        enqueue(task)
    }

    func syncCategory(_ category: Category) {
        let task = SyncCategories(scope: .single(id: category.id), config: config.superLachaise)
        enqueue(task)
    }

    func syncSuperLachaiseObjects() {
        let task = SyncSuperLachaiseObjects(scope: .all)
        enqueue(task)
    }

    func syncSuperLachaiseObject(pointOfInterest: PointOfInterest) {
        let task = SyncSuperLachaiseObjects(scope: .single(id: pointOfInterest.id))
        enqueue(task)
    }

    func syncDatabaseV1Mappings() {
        let task = SyncDatabaseV1Mappings(scope: .all, config: config.superLachaise)
        enqueue(task)
    }

    func syncDatabaseV1Mapping(_ databaseV1Mapping: DatabaseV1Mapping) {
        let task = SyncDatabaseV1Mappings(scope: .single(id: databaseV1Mapping.id),
                                          config: config.superLachaise)
        enqueue(task)
    }

}
