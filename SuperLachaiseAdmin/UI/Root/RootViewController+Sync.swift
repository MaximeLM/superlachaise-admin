//
//  RootViewController+Sync.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 29/11/2017.
//

import Cocoa

extension RootViewController {

    @IBAction func syncOpenStreetMapElements(_ sender: Any?) {
        taskController.syncOpenStreetMapElements()
    }

}
