//
//  TaskController+SuperLachaise.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 24/03/2018.
//

import Foundation

extension TaskController {

    func syncCategories() {
        let task = SyncCategories(scope: .all,
                                  config: config.superLachaise,
                                  performInBackground: database.performInBackground)
        enqueue(task)
    }

    func syncCategory(_ category: CoreDataCategory) {
        let task = SyncCategories(scope: .single(id: category.id),
                                  config: config.superLachaise,
                                  performInBackground: database.performInBackground)
        enqueue(task)
    }

    func syncSuperLachaiseObjects() {
        let task = SyncSuperLachaiseObjects(scope: .all,
                                            performInBackground: database.performInBackground)
        enqueue(task)
    }

    func syncSuperLachaiseObject(pointOfInterest: CoreDataPointOfInterest) {
        let task = SyncSuperLachaiseObjects(scope: .single(id: pointOfInterest.id),
                                            performInBackground: database.performInBackground)
        enqueue(task)
    }

    func syncDatabaseV1Mappings() {
        let task = SyncDatabaseV1Mappings(scope: .all,
                                          config: config.superLachaise,
                                          performInBackground: database.performInBackground)
        enqueue(task)
    }

    func syncDatabaseV1Mapping(_ databaseV1Mapping: CoreDataDatabaseV1Mapping) {
        let task = SyncDatabaseV1Mappings(scope: .single(id: databaseV1Mapping.id),
                                          config: config.superLachaise,
                                          performInBackground: database.performInBackground)
        enqueue(task)
    }

}
