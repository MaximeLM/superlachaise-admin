//
//  CommonsFile+Size.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 04/03/2018.
//

import Foundation

extension CommonsFile {

    var hasValidSize: Bool {
        return width > 0 && height > 0
    }

    var ratio: Float {
        return hasValidSize ? (width / height) : 1
    }

}