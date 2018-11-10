//
//  CoreDataCommonsFile+Size.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 10/11/2018.
//

import Foundation

extension CoreDataCommonsFile {

    var hasValidSize: Bool {
        return width > 0 && height > 0
    }

    var ratio: Float {
        return hasValidSize ? (width / height) : 1
    }

}
