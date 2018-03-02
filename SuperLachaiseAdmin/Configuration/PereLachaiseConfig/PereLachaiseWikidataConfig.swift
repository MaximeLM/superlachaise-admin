//
//  PereLachaiseWikidataConfig.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 10/12/2017.
//

import Foundation

struct PereLachaiseWikidataConfig: WikidataConfig {

    let languages: [String] = ["fr", "en"]

    let customSecondaryWikidataIds: [WikidataEntityName: [WikidataEntityName]] = [
        .malikOussekine: [.deathOfMalikOussekine],
    ]

}

private extension WikidataEntityName {

    static let malikOussekine = WikidataEntityName(rawValue: "Q15860323")
    static let deathOfMalikOussekine = WikidataEntityName(rawValue: "Q16204221")

}
