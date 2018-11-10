//
//  CoreDataLocalizedEntry+Protocols.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 10/11/2018.
//

import CoreData
import Foundation

extension CoreDataLocalizedEntry: KeyedObject {

    typealias Key = (entry: CoreDataEntry, language: String)

    static func attributes(key: Key) -> [String: Any] {
        return ["entry": key.entry, "language": key.language]
    }

}
