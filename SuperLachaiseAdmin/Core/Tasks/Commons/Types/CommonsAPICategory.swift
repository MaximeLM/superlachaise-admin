//
//  CommonsAPICategory.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 20/02/2018.
//

import Foundation

struct CommonsAPICategory: Decodable {

    let title: String
    let missing: String?

    let revisions: [CommonsAPICategoryRevision]?

    var description: String {
        return title
    }

}

struct CommonsAPICategoryRevision: Decodable {

    let wikitext: String

    enum CodingKeys: String, CodingKey {
        case wikitext = "*"
    }

}
