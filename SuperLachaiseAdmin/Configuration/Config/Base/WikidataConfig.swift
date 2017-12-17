//
//  WikidataConfig.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 10/12/2017.
//

import Foundation

protocol WikidataConfig {

    var languages: [String] { get }

    var validLocations: [WikidataEntityName] { get }

    var customSecondaryWikidataIds: [WikidataEntityName: [WikidataEntityName]] { get }

}
