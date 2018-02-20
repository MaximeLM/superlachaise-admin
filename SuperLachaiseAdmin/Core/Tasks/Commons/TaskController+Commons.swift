//
//  TaskController+Commons.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 20/02/2018.
//

import Foundation

extension TaskController {

    func syncCommonsCategories() {
        let task = SyncCommonsCategories(scope: .all,
                                         endpoint: commonsAPIEndpoint)
        enqueue(task)
    }

    func syncCommonsCategory(_ commonsCategory: CommonsCategory) {
        let task = SyncCommonsCategories(scope: .single(name: commonsCategory.name),
                                         endpoint: commonsAPIEndpoint)
        enqueue(task)
    }

}
