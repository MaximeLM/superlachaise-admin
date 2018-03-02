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

    static let instanceOf = WikidataPropertyName(rawValue: "P31")

    static let of = WikidataPropertyName(rawValue: "P642")

    static let commemorates = WikidataPropertyName(rawValue: "P547")
    static let mainSubject = WikidataPropertyName(rawValue: "P921")

    static let occupation = WikidataPropertyName(rawValue: "P106")
    static let sexOrGender = WikidataPropertyName(rawValue: "P21")

    static let dateOfBirth = WikidataPropertyName(rawValue: "P569")
    static let dateOfDeath = WikidataPropertyName(rawValue: "P570")

    static let placeOfInterment = WikidataPropertyName(rawValue: "P119")

    static let commonsCategory = WikidataPropertyName(rawValue: "P373")

    static let image = WikidataPropertyName(rawValue: "P18")
    static let imageOfGrave = WikidataPropertyName(rawValue: "P1442")

}
