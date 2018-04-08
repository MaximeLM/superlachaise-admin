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
                                       endpoint: wikidataAPIEndpoint)
        enqueue(task)
    }

    func syncWikidataEntry(_ wikidataEntry: WikidataEntry) {
        let task = SyncWikidataEntries(scope: .single(id: wikidataEntry.id),
                                       config: config.wikidata,
                                       endpoint: wikidataAPIEndpoint)
        enqueue(task)
    }

    func syncWikidataCategories() {
        let task = SyncWikidataCategories(scope: .all,
                                          config: config.wikidata,
                                          endpoint: wikidataAPIEndpoint)
        enqueue(task)
    }

    func syncWikidataCategory(_ wikidataCategory: WikidataCategory) {
        let task = SyncWikidataCategories(scope: .single(id: wikidataCategory.id),
                                          config: config.wikidata,
                                          endpoint: wikidataAPIEndpoint)
        enqueue(task)
    }

}
