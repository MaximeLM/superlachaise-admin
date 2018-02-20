//
//  MainWindowController+Tasks.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 20/12/2017.
//

import Cocoa

extension MainWindowController {

    @IBAction func syncCurrentModel(_ sender: Any?) {
        guard let model = model.value as? Syncable else {
            return
        }
        model.sync(taskController: taskController)
    }

    @IBAction func cancelCurrentTask(_ sender: Any?) {
        taskController.runningTasks.value.first?.cancel()
    }

    @IBAction func syncOpenStreetMapElements(_ sender: Any?) {
        taskController.syncOpenStreetMapElements()
    }

    @IBAction func syncWikidataEntries(_ sender: Any?) {
        taskController.syncWikidataEntries()
    }

    @IBAction func syncWikipediaPages(_ sender: Any?) {
        taskController.syncWikipediaPages()
    }

    @IBAction func syncCommonsCategories(_ sender: Any?) {
        taskController.syncCommonsCategories()
    }

}
