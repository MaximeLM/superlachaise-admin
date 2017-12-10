//
//  WikidataClaim.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 10/12/2017.
//

import Foundation

struct WikidataClaim: Decodable {

    let mainsnak: WikidataClaimSnak
    let qualifiers: [String: [WikidataClaimSnak]]?

}

struct WikidataClaimSnak: Decodable {

    let property: String
    let datavalue: WikidataClaimDatavalue?

}

struct WikidataClaimDatavalue: Decodable {

    let type: String
    let value: WikidataClaimValue?

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.type = try container.decode(String.self, forKey: .type)
        switch type {
        case "string":
            value = .string(try container.decode(String.self, forKey: .value))
        case "wikibase-item":
            value = .entity(try container.decode(WikidataClaimEntityValue.self, forKey: .value))
        case "time":
            value = .time(try container.decode(WikidataClaimTimeValue.self, forKey: .value))
        default:
            value = nil
        }
    }

    enum CodingKeys: String, CodingKey {
        case type
        case value
    }

}

enum WikidataClaimValue {

    case string(String)
    case entity(WikidataClaimEntityValue)
    case time(WikidataClaimTimeValue)

}

struct WikidataClaimEntityValue: Decodable {

    let numericId: Int64
    let id: String

    enum CodingKeys: String, CodingKey {
        case numericId = "numeric-id"
        case id
    }

}

struct WikidataClaimTimeValue: Decodable {

    let time: String
    let timezone: Int
    let precision: Int
    let calendarmodel: String

}
