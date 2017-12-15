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

    let ignoredElements: [OpenStreetMapId] = [
        OpenStreetMapId(elementType: .node, numericId: 1688357881),
        OpenStreetMapId(elementType: .node, numericId: 5058142865),
        OpenStreetMapId(elementType: .node, numericId: 5058142866),
        OpenStreetMapId(elementType: .node, numericId: 5220080010),
        OpenStreetMapId(elementType: .node, numericId: 5220080011),
        OpenStreetMapId(elementType: .node, numericId: 5220085953),
        OpenStreetMapId(elementType: .node, numericId: 5221404534),
    ]

}
