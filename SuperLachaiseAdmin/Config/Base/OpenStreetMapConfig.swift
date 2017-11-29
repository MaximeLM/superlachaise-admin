//
//  OpenStreetMapConfig.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 29/11/2017.
//

import Foundation

protocol OpenStreetMapConfig {

    var boundingBox: BoundingBox { get }

    var fetchedTags: [String] { get }

}
