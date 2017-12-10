//
//  TaskController+Wikidata.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 10/12/2017.
//

import Foundation

extension TaskController {

    func syncWikidataEntries() {
        let task = SyncWikidataEntries(scope: .all, endpoint: wikidataAPIEndpoint)
        enqueue(task)
    }

    func syncWikidataEntries(_ wikidataEntries: [WikidataEntry]) {
        let wikidataIds = wikidataEntries.map { $0.wikidataId }
        let task = SyncWikidataEntries(scope: .list(wikidataIds: wikidataIds), endpoint: wikidataAPIEndpoint)
        enqueue(task)
    }

}
