//
//  WikidataEntityName.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 12/12/2017.
//

import Foundation

struct WikidataEntityName: Hashable {

    let rawValue: String

    var hashValue: Int {
        return rawValue.hashValue
    }

    static func == (lhs: WikidataEntityName, rhs: WikidataEntityName) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }

}

extension WikidataEntityName {

    static let human = WikidataEntityName(rawValue: "Q5")

    static let grave = WikidataEntityName(rawValue: "Q173387")
    static let tomb = WikidataEntityName(rawValue: "Q381885")
    static let cardiotaph = WikidataEntityName(rawValue: "Q18168545")

    static let monument = WikidataEntityName(rawValue: "Q4989906")
    static let memorial = WikidataEntityName(rawValue: "Q5003624")
    static let warMemorial = WikidataEntityName(rawValue: "Q575759")

}
