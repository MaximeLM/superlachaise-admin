//
//  WikidataEntityResult.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 10/12/2017.
//

import Foundation

struct WikidataEntityResult: Decodable {

    let id: String

    let labels: [String: WikidataEntityLocalizedValue]
    let descriptions: [String: WikidataEntityLocalizedValue]
    let claims: [String: [WikidataClaim]]
    let sitelinks: [String: WikidataSitelink]

}

struct WikidataEntityLocalizedValue: Decodable {

    let language: String
    let value: String

}

struct WikidataSitelink: Decodable {

    let site: String
    let title: String

}
