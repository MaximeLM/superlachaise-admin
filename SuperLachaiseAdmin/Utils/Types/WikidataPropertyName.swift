//
//  WikidataPropertyName.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 12/12/2017.
//

import Foundation

struct WikidataPropertyName: Hashable {

    let rawValue: String

    var hashValue: Int {
        return rawValue.hashValue
    }

    static func == (lhs: WikidataPropertyName, rhs: WikidataPropertyName) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }

}

extension WikidataPropertyName {

    // MARK: Claims

    static let instanceOf = WikidataPropertyName(rawValue: "P31")
    static let location = WikidataPropertyName(rawValue: "P276")
    static let partOf = WikidataPropertyName(rawValue: "P361")
    static let placeOfBurial = WikidataPropertyName(rawValue: "P119")

}
