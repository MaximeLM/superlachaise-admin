//
//  CoreDataOpenStreetMapElement+Protocols.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 07/11/2018.
//

import Foundation

extension CoreDataOpenStreetMapElement: KeyedObject {

    typealias Key = OpenStreetMapId

    static func attributes(key: Key) -> [String: Any] {
        return ["id": key.rawValue]
    }

}
