//
//  ListViewItem.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 02/12/2017.
//

import Cocoa

protocol ListViewItem: NSObjectProtocol {

    var identifier: String { get }

    var text: String { get }

    var children: [ListViewItem]? { get }

    var reload: ((ListViewItem) -> Void)? { get set }

}
