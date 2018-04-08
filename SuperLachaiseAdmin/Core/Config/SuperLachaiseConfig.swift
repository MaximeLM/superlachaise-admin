//
//  SuperLachaiseConfig.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 24/03/2018.
//

import Foundation

struct SuperLachaiseConfig: Decodable {

    let categories: [ConfigCategory]

    let databaseV1CustomMappings: [String: String]?

}

struct ConfigCategory: Decodable {

    let id: String
    let name: [String: String]

}
