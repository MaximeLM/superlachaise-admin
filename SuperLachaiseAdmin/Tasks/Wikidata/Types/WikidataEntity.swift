//
//  WikidataEntity.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 10/12/2017.
//

import Foundation

struct WikidataEntity: Decodable {

    let id: String

    let labels: [String: WikidataEntityLocalizedValue]
    let descriptions: [String: WikidataEntityLocalizedValue]
    let claims: [String: [WikidataClaim]]
    let sitelinks: [String: WikidataSitelink]

    func claims(_ propertyName: WikidataPropertyName) -> [WikidataClaim] {
        return claims[propertyName.rawValue] ?? []
    }

}

extension WikidataEntity: Hashable {

    static func == (lhs: WikidataEntity, rhs: WikidataEntity) -> Bool {
        return lhs.id == rhs.id
    }

    var hashValue: Int {
        return id.hashValue
    }

}

struct WikidataEntityLocalizedValue: Decodable {

    let language: String
    let value: String

}

struct WikidataSitelink: Decodable {

    let site: String
    let title: String

}
