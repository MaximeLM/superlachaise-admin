//
//  LocalizedEntry+Protocols.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 10/11/2018.
//

import CoreData
import Foundation

extension LocalizedEntry: KeyedObject {

    typealias Key = (entry: Entry, language: String)

    static func attributes(key: Key) -> [String: Any] {
        return ["entry": key.entry, "language": key.language]
    }

}
