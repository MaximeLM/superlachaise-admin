//
//  RootViewController.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 29/11/2017.
//

import Cocoa
import RxSwift

protocol RootViewControllerType: NSObjectProtocol {

    var model: MainWindowModel? { get set }

    var searchValue: String? { get set }

}

final class RootViewController: NSSplitViewController, RootViewControllerType {

    // MARK: Model

    var model: MainWindowModel? {
        get {
            return detailViewController?.model
        }
        set {
            detailViewController?.model = newValue
        }
    }

    // MARK: Subviews

    @IBOutlet var listSplitViewItem: NSSplitViewItem?

    @IBOutlet var detailSplitViewItem: NSSplitViewItem?

    // MARK: Properties

    var searchValue: String? {
        get {
            return listViewController?.searchValue
        }
        set {
            listViewController?.searchValue = newValue
        }
    }

    static var isFirstWindow = true

    // MARK: Child view controllers

    var listViewController: ListViewControllerType? {
        return listSplitViewItem?.viewController as? ListViewControllerType
    }

    var detailViewController: DetailViewControllerType? {
        return detailSplitViewItem?.viewController as? DetailViewControllerType
    }

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        if RootViewController.isFirstWindow {
            RootViewController.isFirstWindow = false
            splitView.autosaveName = NSSplitView.AutosaveName("RootSplitView")
        }
    }

}
