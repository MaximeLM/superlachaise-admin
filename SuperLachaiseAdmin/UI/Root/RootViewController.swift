//
//  RootViewController.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 29/11/2017.
//

import Cocoa

final class RootViewController: NSSplitViewController {

    // MARK: Dependencies

    lazy var realmContext = RealmContext()

    lazy var taskController: TaskController = { [unowned self] in
        TaskController(config: PereLachaiseConfig(), realmContext: self.realmContext)
    }()

    // MARK: Subviews

    private var listViewController: ListViewController? {
        return childViewControllers.flatMap { $0 as? ListViewController }.first
    }

    // MARK: Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        listViewController?.realmContext = realmContext
    }

}
