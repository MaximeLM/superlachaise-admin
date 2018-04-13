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

    @IBAction func syncAll(_ sender: Any?) {
        taskController.syncOpenStreetMapElements()
        taskController.syncWikidataEntries()
        taskController.syncWikidataCategories()
        taskController.syncWikipediaPages()
        taskController.syncCommonsFiles()
        taskController.syncCategories()
        taskController.syncSuperLachaiseObjects()
        taskController.syncDatabaseV1Mappings()
    }

    @IBAction func syncOpenStreetMapElements(_ sender: Any?) {
        taskController.syncOpenStreetMapElements()
    }

    @IBAction func syncWikidataEntries(_ sender: Any?) {
        taskController.syncWikidataEntries()
    }

    @IBAction func syncWikidataCategories(_ sender: Any?) {
        taskController.syncWikidataCategories()
    }

    @IBAction func syncWikipediaPages(_ sender: Any?) {
        taskController.syncWikipediaPages()
    }

    @IBAction func syncCommonsFiles(_ sender: Any?) {
        taskController.syncCommonsFiles()
    }

    @IBAction func syncCategories(_ sender: Any?) {
        taskController.syncCategories()
    }

    @IBAction func syncSuperLachaiseObjects(_ sender: Any?) {
        taskController.syncSuperLachaiseObjects()
    }

    @IBAction func syncDatabaseV1Mappings(_ sender: Any?) {
        taskController.syncDatabaseV1Mappings()
    }

    @IBAction func exportToJSON(_ sender: Any?) {
        let panel = NSOpenPanel()
        panel.message = "Choose the directory in which to save the generated JSON files"
        panel.prompt = "Export"
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        guard panel.runModal() == .OK, let directoryURL = panel.urls.first else {
            return
        }
        taskController.exportToJSON(directoryURL: directoryURL)
    }

}
