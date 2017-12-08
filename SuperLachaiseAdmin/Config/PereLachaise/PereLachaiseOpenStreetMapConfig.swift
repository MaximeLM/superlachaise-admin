//
//  PereLachaiseOpenStreetMapConfig.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 29/11/2017.
//

import Foundation

struct PereLachaiseOpenStreetMapConfig: OpenStreetMapConfig {

    let boundingBox: BoundingBox = (48.8575, 2.3877, 48.8649, 2.4006)

    let fetchedTags: [String] = ["historic=tomb", "historic=memorial"]

}
