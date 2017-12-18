//
//  RootViewController+Actions.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 29/11/2017.
//

import Cocoa

extension RootViewController {

    // MARK: Navigation

    @IBAction func navigationSegmentControlAction(_ sender: NSSegmentedControl) {
        if sender.selectedSegment == 0 {
            goBackInSources()
        } else {
            goForwardInSources()
        }
    }

    // MARK: Sync

    @IBAction func syncOpenStreetMapElements(_ sender: Any?) {
        taskController.syncOpenStreetMapElements()
    }

    @IBAction func syncWikidataEntries(_ sender: Any?) {
        taskController.syncWikidataEntries()
    }

}
