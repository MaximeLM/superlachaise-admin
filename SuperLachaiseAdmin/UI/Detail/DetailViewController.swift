//
//  DetailViewController.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 16/12/2017.
//

import Cocoa

protocol DetailViewControllerType {

    var source: DetailViewSource? { get set }

}

final class DetailViewController: NSViewController, DetailViewControllerType {

    // MARK: Model

    var source: DetailViewSource?

}
