//
//  TaskController+SuperLachaise.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 24/03/2018.
//

import Foundation

extension TaskController {

    func syncPointsOfInterest() {
        let task = SyncPointsOfInterest(scope: .all)
        enqueue(task)
    }

    func syncPointOfInterest(_ pointOfInterest: PointOfInterest) {
        let task = SyncPointsOfInterest(scope: .single(id: pointOfInterest.id))
        enqueue(task)
    }

}
