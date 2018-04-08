//
//  SuperLachaiseConfig.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 24/03/2018.
//

import Foundation

struct SuperLachaiseConfig: Decodable {

    let categoriesNames: [String: [String: String]]

    let databaseV1CustomMappings: [String: String]?

}
