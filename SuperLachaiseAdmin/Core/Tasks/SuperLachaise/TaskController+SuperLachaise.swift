//
//  TaskController+SuperLachaise.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 24/03/2018.
//

import Foundation

extension TaskController {

    func syncSuperLachaisePOIs() {
        let task = SyncSuperLachaisePOIs(scope: .all, config: config.superLachaise)
        enqueue(task)
    }

    func syncSuperLachaisePOI(_ superLachaisePOI: SuperLachaisePOI) {
        guard let superLachaiseId = superLachaisePOI.superLachaiseId else {
            return
        }
        let task = SyncSuperLachaisePOIs(scope: .single(superLachaiseId: superLachaiseId),
                                         config: config.superLachaise)
        enqueue(task)
    }

}
