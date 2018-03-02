//
//  TaskController+Wikipedia.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 21/12/2017.
//

import Foundation

extension TaskController {

    func syncWikipediaPages() {
        let task = SyncWikipediaPages(scope: .all, endpoint: wikipediaAPIEndpoint)
        enqueue(task)
    }

    func syncWikipediaPage(_ wikipediaPage: WikipediaPage) {
        guard let wikipediaId = wikipediaPage.wikipediaId else {
            return
        }
        let task = SyncWikipediaPages(scope: .single(wikipediaId: wikipediaId), endpoint: wikipediaAPIEndpoint)
        enqueue(task)
    }

}
