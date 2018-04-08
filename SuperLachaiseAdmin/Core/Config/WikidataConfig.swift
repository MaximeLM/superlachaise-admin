//
//  WikidataConfig.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 10/12/2017.
//

import Foundation

struct WikidataConfig: Decodable {

    let languages: [String]

    let customSecondaryWikidataIds: [String: [String]]

    let categories: [String: [String]]

}
