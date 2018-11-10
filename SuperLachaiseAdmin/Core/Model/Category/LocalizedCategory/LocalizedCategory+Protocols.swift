//
//  LocalizedCategory+Protocols.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 10/11/2018.
//

import CoreData
import Foundation

extension LocalizedCategory: KeyedObject {

    typealias Key = (category: Category, language: String)

    static func attributes(key: Key) -> [String: Any] {
        return ["category": key.category, "language": key.language]
    }

}
