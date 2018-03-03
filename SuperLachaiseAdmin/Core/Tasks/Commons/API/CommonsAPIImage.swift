//
//  CommonsAPIImage.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 02/03/2018.
//

import Foundation

struct CommonsAPIImage: Decodable, CustomStringConvertible {

    let missing: String?

    let title: String
    let imageinfo: [CommonsAPIImageInfo]?

    var description: String {
        return title
    }

}

struct CommonsAPIImageInfo: Decodable {

    let url: String
    let width: Int
    let height: Int

    let thumburl: String
    let thumbwidth: Int
    let thumbheight: Int

    let extmetadata: CommonsAPIImageExtMetadata

}

struct CommonsAPIImageExtMetadata: Decodable {

    let licenseShortName: CommonsAPIImageMetadataObject?
    let artist: CommonsAPIImageMetadataObject?

    enum CodingKeys: String, CodingKey {
        case licenseShortName = "LicenseShortName"
        case artist = "Artist"
    }

}

struct CommonsAPIImageMetadataObject: Decodable {
    let value: String
}

enum CommonsAPIImageError: Error {
    case multipleImageInfo
}
