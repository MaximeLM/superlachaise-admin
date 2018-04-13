//
//  OpenStreetMapElement+Id.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 28/11/2017.
//

import Foundation

enum OpenStreetMapElementType: String {
    case node, way, relation
}

struct OpenStreetMapId {
    let elementType: OpenStreetMapElementType
    let numericId: Int64
}

extension OpenStreetMapId: Equatable, CustomStringConvertible {

    init?(rawValue: String) {
        let components = rawValue.components(separatedBy: "/")
        guard components.count == 2,
            let elementType = OpenStreetMapElementType(rawValue: components[0]),
            let numericId = Int64(components[1]) else {
                return nil
        }
        self.init(elementType: elementType, numericId: numericId)
    }

    var rawValue: String {
        return "\(elementType.rawValue)/\(numericId)"
    }

    static func == (lhs: OpenStreetMapId, rhs: OpenStreetMapId) -> Bool {
        return lhs.elementType == rhs.elementType && lhs.numericId == rhs.numericId
    }

    var description: String {
        return rawValue
    }

}

extension OpenStreetMapElement {

    var openStreetMapId: OpenStreetMapId? {
        get {
            guard let openStreetMapId = OpenStreetMapId(rawValue: id) else {
                assertionFailure()
                return nil
            }
            return openStreetMapId
        }
        set {
            id = newValue?.rawValue ?? ""
        }
    }

}
