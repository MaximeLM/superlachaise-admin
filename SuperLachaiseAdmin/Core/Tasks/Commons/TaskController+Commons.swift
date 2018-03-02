//
//  TaskController+Commons.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 20/02/2018.
//

import Foundation

extension TaskController {

    func syncCommonsFiles() {
        let task = SyncCommonsFiles(scope: .all, endpoint: commonsAPIEndpoint)
        enqueue(task)
    }

    func syncCommonsFile(_ commonsFile: CommonsFile) {
        let task = SyncCommonsFiles(scope: .single(commonsId: commonsFile.commonsId), endpoint: commonsAPIEndpoint)
        enqueue(task)
    }

}
