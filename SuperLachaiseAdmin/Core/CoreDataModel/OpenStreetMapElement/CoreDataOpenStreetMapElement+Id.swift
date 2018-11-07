//
//  CoreDataOpenStreetMapElement+Id.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 07/11/2018.
//

import Foundation

extension CoreDataOpenStreetMapElement {

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

extension OpenStreetMapId: CoreDataObjectKey {

    typealias CoreDataObject = CoreDataOpenStreetMapElement

    var coreDataAttributes: [String: Any] {
        return ["id": rawValue]
    }

}
