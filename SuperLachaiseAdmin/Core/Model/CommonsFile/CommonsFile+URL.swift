//
//  CommonsFile+URL.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 10/11/2018.
//

import Foundation

extension CommonsFile {

    var imageURL: URL? {
        return URL(string: rawImageURL)
    }

    func thumbnailURL(width: Float) -> URL? {
        let requestWidth = Int(min(width, self.width))
        let urlString = thumbnailURLTemplate.replacingOccurrences(of: "{{width}}", with: "\(requestWidth)")
        return URL(string: urlString)
    }

    func thumbnailURL(height: Float) -> URL? {
        return thumbnailURL(width: height * ratio)
    }

}
