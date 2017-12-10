//
//  OverpassElements.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 28/11/2017.
//

import Foundation

struct OverpassElement: Decodable {

    let type: String
    let id: Int64

    let lat: Double?
    let lon: Double?
    let center: OverpassElementCenter?

    let tags: [String: String]

}

struct OverpassElementCenter: Decodable {

    let lat: Double
    let lon: Double

}
