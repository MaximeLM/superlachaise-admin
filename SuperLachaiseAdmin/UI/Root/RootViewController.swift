//
//  RootViewController.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 29/11/2017.
//

import Cocoa

final class RootViewController: NSSplitViewController {

    let taskController = TaskController(config: PereLachaiseConfig())

    override func viewDidLoad() {
        super.viewDidLoad()
        // Initialize Realm
        do {
            try RealmContext.shared.initialize()
        } catch {
            assertionFailure("\(error)")
        }
    }

}
