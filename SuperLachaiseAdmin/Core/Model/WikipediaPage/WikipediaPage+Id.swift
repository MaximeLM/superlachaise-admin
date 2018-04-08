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

extension WikipediaId: Equatable, CustomStringConvertible {

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

    var description: String {
        return rawValue
    }

}

extension WikipediaPage {

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
