//
//  WikipediaConfig.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 08/04/2018.
//

import Foundation

struct WikipediaConfig: Decodable {

    let extractTrimmedLines: [String]

    let extractSubstitutions: [[String: String]]

}
