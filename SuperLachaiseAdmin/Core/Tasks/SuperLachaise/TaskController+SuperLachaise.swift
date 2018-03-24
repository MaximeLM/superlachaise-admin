//
//  TaskController+SuperLachaise.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 24/03/2018.
//

import Foundation

extension TaskController {

    func syncSuperLachaisePOIs() {
        let task = SyncSuperLachaisePOIs(scope: .all)
        enqueue(task)
    }

    func syncSuperLachaisePOI(_ superLachaisePOI: SuperLachaisePOI) {
        let task = SyncSuperLachaisePOIs(scope: .single(wikidataId: superLachaisePOI.wikidataId))
        enqueue(task)
    }

}
