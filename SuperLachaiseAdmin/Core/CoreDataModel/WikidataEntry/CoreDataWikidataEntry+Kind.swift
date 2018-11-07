//
//  CoreDataWikidataEntry+Kind.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 07/11/2018.
//

import Foundation

extension CoreDataWikidataEntry {

    var kind: EntryKind? {
        get {
            return EntryKind(rawValue: rawKind)
        }
        set {
            rawKind = newValue?.rawValue ?? ""
        }
    }

}
