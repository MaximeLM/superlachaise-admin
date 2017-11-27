//
//  URL.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 28/11/2017.
//

import Foundation

extension URL {

    static func with(_ string: String) -> URL {
        guard let url = URL(string: string) else {
            fatalError("Invalid URL string \(string)")
        }
        return url
    }

}
