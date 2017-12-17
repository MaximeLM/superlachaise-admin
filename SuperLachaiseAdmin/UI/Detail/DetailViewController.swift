//
//  DetailViewController.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 16/12/2017.
//

import Cocoa

protocol DetailViewControllerType {

    var model: DetailViewModel? { get set }

    func didSwitchSource()

}

final class DetailViewController: NSViewController, DetailViewControllerType {

    // MARK: Model

    var model: DetailViewModel? {
        didSet {
            stackView?.setViews(model?.views() ?? [], in: .top)
        }
    }

    func didSwitchSource() {
        if let documentView = scrollView?.documentView {
            documentView.scroll(NSPoint(x: 0, y: documentView.bounds.height))
        }
    }

    // MARK: Subviews

    @IBOutlet weak var  scrollView: NSScrollView?

    @IBOutlet weak var  stackView: NSStackView?

}
