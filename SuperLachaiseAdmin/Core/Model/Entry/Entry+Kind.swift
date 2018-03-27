//
//  Entry+Kind.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 25/03/2018.
//

import Foundation

enum EntryKind: String {
    case person, grave, monument
}

extension Entry {

    var kind: EntryKind? {
        get {
            return EntryKind(rawValue: rawKind)
        }
        set {
            rawKind = newValue?.rawValue ?? ""
        }
    }

}