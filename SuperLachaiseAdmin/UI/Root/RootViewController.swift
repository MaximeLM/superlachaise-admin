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

    // MARK: Subviews

    var listViewController: ListViewControllerType?

    var detailViewController: DetailViewControllerType?

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        listViewController = childViewControllers.flatMap { $0 as? ListViewControllerType }.first
        detailViewController = childViewControllers.flatMap { $0 as? DetailViewControllerType }.first

        listViewController?.didSelectDetailViewSource = { [weak self] detailViewSource in
            self?.view.window?.title = detailViewSource.detailViewTitle
            self?.detailViewController?.source = detailViewSource
        }
    }

}
