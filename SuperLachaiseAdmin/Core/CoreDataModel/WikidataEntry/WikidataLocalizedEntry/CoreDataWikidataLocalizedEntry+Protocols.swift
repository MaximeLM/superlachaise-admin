//
//  CoreDataWikidataLocalizedEntry+Protocols.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 10/11/2018.
//

import CoreData
import Foundation

extension CoreDataWikidataLocalizedEntry: KeyedObject {

    typealias Key = (wikidataEntry: CoreDataWikidataEntry, language: String)

    static func attributes(key: Key) -> [String: Any] {
        return ["wikidataEntry": key.wikidataEntry, "language": key.language]
    }

}
