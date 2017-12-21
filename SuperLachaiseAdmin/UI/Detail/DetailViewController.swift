//
//  DetailViewController.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 16/12/2017.
//

import Cocoa

protocol DetailViewControllerType: NSObjectProtocol {

    var model: MainWindowModel? { get set }

    var refreshModel: MainWindowModel? { get set }

}

final class DetailViewController: NSViewController, DetailViewControllerType {

    // MARK: Model

    var model: MainWindowModel? {
        didSet {
            // Scroll to top on model change
            if let documentView = scrollView?.documentView {
                documentView.scroll(NSPoint(x: 0, y: documentView.bounds.height))
            }
        }
    }

    var refreshModel: MainWindowModel? {
        didSet {
            // Bind the model to the stack view
            let views = refreshModel?.detailViewModel().views() ?? []
            stackView?.setViews(views, in: .top)
        }
    }

    // MARK: Subviews

    @IBOutlet var scrollView: NSScrollView?

    @IBOutlet var stackView: NSStackView?

}
