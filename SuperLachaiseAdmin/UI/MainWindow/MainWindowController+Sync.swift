//
//  MainWindowController+Sync.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 20/12/2017.
//

import Cocoa

extension MainWindowController {

    @IBAction func syncOpenStreetMapElements(_ sender: Any?) {
        taskController.syncOpenStreetMapElements()
    }

    @IBAction func syncWikidataEntries(_ sender: Any?) {
        taskController.syncWikidataEntries()
    }

}
