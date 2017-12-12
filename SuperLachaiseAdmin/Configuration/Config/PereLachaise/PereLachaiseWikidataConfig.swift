//
//  PereLachaiseWikidataConfig.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 10/12/2017.
//

import Foundation

struct PereLachaiseWikidataConfig: WikidataConfig {

    let languages: [String] = ["fr", "en"]

    let validLocations: [WikidataEntityName] = [
        .pereLachaiseCemetery,
        .pereLachaiseCrematorium,
    ]

}

private extension WikidataEntityName {

    static let pereLachaiseCemetery = WikidataEntityName(rawValue: "Q311")
    static let pereLachaiseCrematorium = WikidataEntityName(rawValue: "Q3006253")

}
