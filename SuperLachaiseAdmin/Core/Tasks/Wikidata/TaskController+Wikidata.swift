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

    func syncWikidataEntries(ids wikidataIds: [String]) {
        let task = SyncWikidataEntries(scope: .list(wikidataIds: wikidataIds),
                                       config: config.wikidata,
                                       endpoint: wikidataAPIEndpoint)
        enqueue(task)
    }

}
