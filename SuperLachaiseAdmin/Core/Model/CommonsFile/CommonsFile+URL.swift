//
//  CommonsFile+URL.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 02/03/2018.
//

import Foundation

extension CommonsFile {

    var imageURL: URL? {
        return URL(string: rawImageURL)
    }

}
