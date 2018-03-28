//
//  OpenStreetMapConfig.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 29/11/2017.
//

import Foundation

struct OpenStreetMapConfig: Decodable {

    let boundingBox: BoundingBox

    let fetchedTags: [String]

    let ignoredElements: [OpenStreetMapId]

}

extension BoundingBox: Decodable {

    init(from decoder: Decoder) throws {
        let coordinates = try decoder.singleValueContainer().decode([Double].self)
        guard coordinates.count == 4 else {
            throw Errors.invalidBoundingBox(coordinates)
        }
        self.init(minLatitude: coordinates[0],
                  minLongitude: coordinates[1],
                  maxLatitude: coordinates[2],
                  maxLongitude: coordinates[3])
    }

}

extension OpenStreetMapId: Decodable {

    init(from decoder: Decoder) throws {
        let rawValue = try decoder.singleValueContainer().decode(String.self)
        guard let openStreetMapId = OpenStreetMapId(rawValue: rawValue) else {
            throw Errors.invalidInvalidOpenStreetMapId(rawValue)
        }
        self = openStreetMapId
    }

}
