//
//  CoreDataEntry+Kind.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 10/11/2018.
//

import Foundation

enum EntryKind: String {
    case person, grave, monument
}

extension CoreDataEntry {

    var kind: EntryKind? {
        get {
            return EntryKind(rawValue: rawKind)
        }
        set {
            rawKind = newValue?.rawValue ?? ""
        }
    }

}
