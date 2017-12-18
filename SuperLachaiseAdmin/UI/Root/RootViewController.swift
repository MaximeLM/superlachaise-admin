//
//  RootViewController.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 29/11/2017.
//

import Cocoa
import RealmSwift

final class RootViewController: NSSplitViewController {

    // MARK: Dependencies

    lazy var taskController = AppContainer.taskController

    // MARK: Subviews

    @IBOutlet weak var listSplitViewItem: NSSplitViewItem?

    @IBOutlet weak var detailSplitViewItem: NSSplitViewItem?

    var listViewController: ListViewControllerType?

    var detailViewController: DetailViewControllerType?

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        listViewController = listSplitViewItem?.viewController as? ListViewControllerType
        detailViewController = detailSplitViewItem?.viewController as? DetailViewControllerType

        listViewController?.didSelectObject = { [weak self] object in
            guard let source = object as? DetailViewSource else {
                return
            }
            guard source.identifier != self?.source?.identifier else {
                return
            }
            self?.source = source
        }

    }

    // MARK: Model

    var source: DetailViewSource? {
        get {
            return detailViewController?.source
        }
        set {
            detailViewController?.source = newValue
        }
    }

}
