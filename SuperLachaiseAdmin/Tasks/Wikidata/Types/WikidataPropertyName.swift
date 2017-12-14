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

    static let of = WikidataPropertyName(rawValue: "P642")

    static let commemorates = WikidataPropertyName(rawValue: "P547")
    static let mainSubject = WikidataPropertyName(rawValue: "P921")

    static let occupation = WikidataPropertyName(rawValue: "P106")
    static let sexOrGender = WikidataPropertyName(rawValue: "P21")

}
