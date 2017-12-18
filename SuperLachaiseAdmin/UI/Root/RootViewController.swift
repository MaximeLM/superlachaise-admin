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

    // MARK: Other views

    var window: NSWindow? {
        return view.window
    }

    var listViewController: ListViewControllerType? {
        return listSplitViewItem?.viewController as? ListViewControllerType
    }

    var detailViewController: DetailViewControllerType? {
        return detailSplitViewItem?.viewController as? DetailViewControllerType
    }

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        listViewController?.didSelectObject = { [weak self] object in
            guard let source = object as? DetailViewSource else {
                return
            }
            guard source.identifier != self?.source?.identifier else {
                return
            }
            self?.source = source
        }

        detailViewController?.didChangeTitle = { [weak self] title in
            self?.window?.title = title ?? "SuperLachaiseAdmin"
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
