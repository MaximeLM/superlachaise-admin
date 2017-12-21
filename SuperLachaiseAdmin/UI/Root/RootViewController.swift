//
//  RootViewController.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 29/11/2017.
//

import Cocoa
import RealmSwift
import RxSwift

protocol RootViewControllerType: NSObjectProtocol {

    var didSingleClickModel: Observable<MainWindowModel>? { get }

    var didDoubleClickModel: Observable<MainWindowModel>? { get }

    var model: Variable<MainWindowModel?>? { get }

    var refreshModel: Variable<MainWindowModel?>? { get }

}

final class RootViewController: NSSplitViewController, RootViewControllerType {

    // MARK: Subviews

    @IBOutlet var listSplitViewItem: NSSplitViewItem?

    @IBOutlet var detailSplitViewItem: NSSplitViewItem?

    // MARK: Properties

    var didSingleClickModel: Observable<MainWindowModel>? {
        return listViewController?.didSingleClickModel
    }

    var didDoubleClickModel: Observable<MainWindowModel>? {
        return listViewController?.didDoubleClickModel
    }

    var model: Variable<MainWindowModel?>? {
        return detailViewController?.model
    }

    var refreshModel: Variable<MainWindowModel?>? {
        return detailViewController?.refreshModel
    }

    // MARK: Child view controllers

    var listViewController: ListViewControllerType? {
        return listSplitViewItem?.viewController as? ListViewControllerType
    }

    var detailViewController: DetailViewControllerType? {
        return detailSplitViewItem?.viewController as? DetailViewControllerType
    }

}
