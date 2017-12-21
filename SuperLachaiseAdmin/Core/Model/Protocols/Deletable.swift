//
//  Deletable.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 29/11/2017.
//

import Foundation

protocol Deletable {

    var deleted: Bool { get set }

    func delete()

}
