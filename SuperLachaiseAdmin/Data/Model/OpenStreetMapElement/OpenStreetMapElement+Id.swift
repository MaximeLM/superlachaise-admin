//
//  OpenStreetMapElement+Id.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 28/11/2017.
//

import Foundation

enum OpenStreetMapElementType: String {
    case node, way, relation
    case unknown = ""
}

struct OpenStreetMapId {
    let elementType: OpenStreetMapElementType
    let numericId: Int64
}

extension OpenStreetMapElement {

    var elementType: OpenStreetMapElementType {
        get {
            return OpenStreetMapElementType(rawValue: rawElementType) ?? .unknown
        }
        set {
            rawElementType = newValue.rawValue
        }
    }

    var openStreetMapId: OpenStreetMapId {
        get {
            return OpenStreetMapId(elementType: elementType, numericId: numericId)
        }
        set {
            elementType = newValue.elementType
            numericId = newValue.numericId
        }
    }

}
