//
//  DetailViewController.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 16/12/2017.
//

import Cocoa

protocol DetailViewControllerType {

    var model: DetailViewModel? { get set }

}

final class DetailViewController: NSViewController, DetailViewControllerType {

    // MARK: Model

    var model: DetailViewModel? {
        didSet {
            stackView?.setViews(model?.detailSubviews() ?? [], in: .top)
        }
    }

    // MARK: Subviews

    @IBOutlet weak var  stackView: NSStackView?

}
