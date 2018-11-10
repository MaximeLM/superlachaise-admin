//
//  TaskController+Wikidata.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 10/12/2017.
//

import Foundation

extension TaskController {

    func syncWikidataEntries() {
        let task = SyncWikidataEntries(scope: .all,
                                       config: config.wikidata,
                                       endpoint: wikidataAPIEndpoint,
                                       performInBackground: database.performInBackground)
        enqueue(task)
    }

    func syncWikidataEntry(_ wikidataEntry: CoreDataWikidataEntry) {
        let task = SyncWikidataEntries(scope: .single(id: wikidataEntry.id),
                                       config: config.wikidata,
                                       endpoint: wikidataAPIEndpoint,
                                       performInBackground: database.performInBackground)
        enqueue(task)
    }

    func syncWikidataCategories() {
        let task = SyncWikidataCategories(scope: .all,
                                          config: config.wikidata,
                                          endpoint: wikidataAPIEndpoint,
                                          performInBackground: database.performInBackground)
        enqueue(task)
    }

    func syncWikidataCategory(_ wikidataCategory: CoreDataWikidataCategory) {
        let task = SyncWikidataCategories(scope: .single(id: wikidataCategory.id),
                                          config: config.wikidata,
                                          endpoint: wikidataAPIEndpoint,
                                          performInBackground: database.performInBackground)
        enqueue(task)
    }

}
