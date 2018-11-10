//
//  CoreDataWikipediaPage+Id.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 10/11/2018.
//

import Foundation

extension CoreDataWikipediaPage {

    var wikipediaId: WikipediaId? {
        get {
            guard let wikipediaId = WikipediaId(rawValue: id) else {
                assertionFailure()
                return nil
            }
            return wikipediaId
        }
        set {
            id = newValue?.rawValue ?? ""
        }
    }

}
