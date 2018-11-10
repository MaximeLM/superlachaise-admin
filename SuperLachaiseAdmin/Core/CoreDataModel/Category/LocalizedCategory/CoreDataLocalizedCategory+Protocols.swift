//
//  CoreDataLocalizedCategory+Protocols.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 10/11/2018.
//

import CoreData
import Foundation

extension CoreDataLocalizedCategory: KeyedObject {

    typealias Key = (category: CoreDataCategory, language: String)

    static func attributes(key: Key) -> [String: Any] {
        return ["category": key.category, "language": key.language]
    }

}
