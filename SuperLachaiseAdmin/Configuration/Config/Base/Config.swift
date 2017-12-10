//
//  Config.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 29/11/2017.
//

import Foundation

protocol Config {

    var languages: [String] { get }

    var openStreetMap: OpenStreetMapConfig { get }

    var wikidata: WikidataConfig { get }

}
