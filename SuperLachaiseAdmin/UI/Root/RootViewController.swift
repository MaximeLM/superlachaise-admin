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

    var refreshModel: MainWindowModel? { get set }

    var didSingleClickModel: Observable<MainWindowModel>? { get }

    var didDoubleClickModel: Observable<MainWindowModel>? { get }

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

    var refreshModel: MainWindowModel? {
        get {
            return detailViewController?.refreshModel
        }
        set {
            detailViewController?.refreshModel = newValue
        }
    }

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

    var searchValue: String? {
        get {
            return listViewController?.searchValue
        }
        set {
            listViewController?.searchValue = newValue
        }
    }

    // MARK: Child view controllers

    var listViewController: ListViewControllerType? {
        return listSplitViewItem?.viewController as? ListViewControllerType
    }

    var detailViewController: DetailViewControllerType? {
        return detailSplitViewItem?.viewController as? DetailViewControllerType
    }

}
