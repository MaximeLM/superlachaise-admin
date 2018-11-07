//
//  CoreDataWikidataEntry+Protocols.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 07/11/2018.
//

import Foundation

extension CoreDataWikidataEntry: KeyedObject {

    typealias Key = String

    static func attributes(key: Key) -> [String: Any] {
        return ["id": key]
    }

}
