//
//  WikipediaAPIPage.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 22/12/2017.
//

import Foundation

struct WikipediaAPIPage: Decodable, CustomStringConvertible {

    let missing: String?

    let title: String
    let revisions: [WikipediaAPIPageRevision]?
    let extract: String?

    var description: String {
        return title
    }

}

struct WikipediaAPIPageRevision: Decodable {

    let wikitext: String

    enum CodingKeys: String, CodingKey {
        case wikitext = "*"
    }

}
