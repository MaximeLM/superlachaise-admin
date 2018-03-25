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

    func qualifiers(_ propertyName: WikidataPropertyName) -> [WikidataClaimSnak] {
        return qualifiers?[propertyName.rawValue] ?? []
    }

}

struct WikidataClaimSnak: Decodable {

    let property: String
    let datavalue: WikidataClaimDatavalue?

    var stringValue: String? {
        guard let stringValue = datavalue?.stringValue else {
            Logger.warning("[\(property)] Expected stringValue")
            return nil
        }
        return stringValue
    }

    var entityName: WikidataEntityName? {
        guard let entityValue = datavalue?.entityValue else {
            Logger.warning("[\(property)] Expected entityValue")
            return nil
        }
        return WikidataEntityName(rawValue: entityValue.id)
    }

    var timeValue: WikidataClaimTimeValue? {
        guard let timeValue = datavalue?.timeValue else {
            Logger.warning("[\(property)] Expected timeValue")
            return nil
        }
        return timeValue
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
    let precision: Int

    private static let dateFormatter = ISO8601DateFormatter()

    func date() throws -> Date {
        let prefix = time.first
        let isoString = String(time.dropFirst())
        guard prefix == "+" else {
            throw WikidataClaimTimeValueError.invalidTimePrefix(prefix)
        }
        guard let date = WikidataClaimTimeValue.dateFormatter.date(from: isoString) else {
            throw WikidataClaimTimeValueError.invalidTimeFormat(isoString)
        }
        return date
    }

    func datePrecision() throws -> EntryDate.Precision {
        switch precision {
        case 9:
            return .year
        case 10:
            return .month
        case 11:
            return .day
        default:
            throw WikidataClaimTimeValueError.invalidPrecision(precision)
        }
    }

    func entryDate() throws -> EntryDate {
        return EntryDate(date: try date(), precision: try datePrecision())
    }

}

enum WikidataClaimTimeValueError: Error {
    case invalidTimePrefix(Character?)
    case invalidTimeFormat(String)
    case invalidPrecision(Int)
}
