//
//  TaskController+Export.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 31/03/2018.
//

import Foundation

extension TaskController {

    func exportToJSON(directoryURL: URL) {
        let task = ExportToJSON(directoryURL: directoryURL,
                                config: config.export,
                                performInBackground: database.performInBackground)
        enqueue(task)
    }

}
