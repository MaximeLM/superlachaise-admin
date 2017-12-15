//
//  RootViewController.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 29/11/2017.
//

import Cocoa

final class RootViewController: NSSplitViewController {

    // MARK: Dependencies

    lazy var realmContext = AppContainer.realmContext

    lazy var taskController = AppContainer.taskController

}
