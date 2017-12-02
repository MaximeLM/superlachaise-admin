//
//  ListViewItem.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 02/12/2017.
//

import Cocoa
import RxSwift

protocol ListViewItem: NSObjectProtocol {

    var text: String { get }

    var children: Variable<[ListViewItem]>? { get }

}
