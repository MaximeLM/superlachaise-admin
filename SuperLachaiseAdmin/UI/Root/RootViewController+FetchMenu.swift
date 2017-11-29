//
//  RootViewController+FetchMenu.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 29/11/2017.
//

import Cocoa

extension RootViewController {

    @IBAction func fetchOpenStreetMapElements(_ sender: Any?) {
        taskController.fetchOpenStreetMapElements()
    }

}
