//
//  Config.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 29/11/2017.
//

import Foundation

struct Config: Decodable {

    let openStreetMap: OpenStreetMapConfig
    let wikidata: WikidataConfig
    let superLachaise: SuperLachaiseConfig
    let export: ExportConfig

}
