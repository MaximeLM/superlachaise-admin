//
//  TaskController.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 29/11/2017.
//

import Foundation

final class TaskController {

    let config: Config

    let operationQueue: OperationQueue

    init(config: Config) {
        self.config = config
        self.operationQueue = OperationQueue()
    }

}
