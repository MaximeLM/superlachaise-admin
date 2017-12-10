//
//  PereLachaiseConfig.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 29/11/2017.
//

import Foundation

struct PereLachaiseConfig: Config {

    let languages: [String] = ["fr", "en"]

    let openStreetMap: OpenStreetMapConfig = PereLachaiseOpenStreetMapConfig()

    let wikidata: WikidataConfig = PereLachaiseWikidataConfig()

}
