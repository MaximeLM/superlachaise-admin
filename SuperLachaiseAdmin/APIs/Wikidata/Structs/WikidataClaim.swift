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

    func qualifiers(_ propertyName: WikidataPropertyName) -> [WikidataClaimSnak]? {
        return qualifiers?[propertyName.rawValue]
    }

}

struct WikidataClaimSnak: Decodable {

    let property: String
    let datavalue: WikidataClaimDatavalue?

    var stringValue: String? {
        return datavalue?.stringValue
    }

    var entityValue: WikidataEntityName? {
        guard let entityValue = datavalue?.entityValue else {
            return nil
        }
        return WikidataEntityName(rawValue: entityValue.id)
    }

    var timeValue: WikidataClaimTimeValue? {
        return datavalue?.timeValue
    }

}

struct WikidataClaimDatavalue: Decodable {

    let type: String
    let stringValue: String?
    let entityValue: WikidataClaimEntityValue?
    let timeValue: WikidataClaimTimeValue?

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.type = try container.decode(String.self, forKey: .type)
        switch type {
        case "string":
            stringValue = try container.decode(String.self, forKey: .value)
            entityValue = nil
            timeValue = nil
        case "wikibase-entityid":
            stringValue = nil
            entityValue = try container.decode(WikidataClaimEntityValue.self, forKey: .value)
            timeValue = nil
        case "time":
            stringValue = nil
            entityValue = nil
            timeValue = try container.decode(WikidataClaimTimeValue.self, forKey: .value)
        default:
            stringValue = nil
            entityValue = nil
            timeValue = nil
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
