//
//  TaskController+SuperLachaise.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 24/03/2018.
//

import Foundation

extension TaskController {

    func syncSuperLachaiseObjects() {
        let task = SyncSuperLachaiseObjects(scope: .all)
        enqueue(task)
    }

    func syncSuperLachaiseObject(pointOfInterest: PointOfInterest) {
        let task = SyncSuperLachaiseObjects(scope: .single(id: pointOfInterest.id))
        enqueue(task)
    }

}
