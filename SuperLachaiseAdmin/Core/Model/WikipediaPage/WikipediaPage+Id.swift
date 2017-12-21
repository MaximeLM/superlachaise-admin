//
//  WikipediaPage+Id.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 21/12/2017.
//

import Foundation

struct WikipediaId {
    let language: String
    let title: String
}

extension WikipediaId: Equatable {

    init?(rawValue: String) {
        let components = rawValue.components(separatedBy: "/")
        guard components.count == 2 else {
                return nil
        }
        self.init(language: components[0], title: components[1])
    }

    var rawValue: String {
        return "\(language)/\(title)"
    }

    static func == (lhs: WikipediaId, rhs: WikipediaId) -> Bool {
        return lhs.language == rhs.language && lhs.title == rhs.title
    }

}

extension WikipediaPage {

    var wikipediaId: WikipediaId? {
        get {
            guard let wikipediaId = WikipediaId(rawValue: rawWikipediaId) else {
                Logger.warning("Invalid rawWikipediaId: \(rawWikipediaId)")
                return nil
            }
            return wikipediaId
        }
        set {
            rawWikipediaId = newValue?.rawValue ?? ""
        }
    }

}
