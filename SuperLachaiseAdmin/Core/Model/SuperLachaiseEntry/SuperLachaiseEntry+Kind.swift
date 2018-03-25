//
//  SuperLachaiseEntry+Kind.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 25/03/2018.
//

import Foundation

extension SuperLachaiseEntry {

    var kind: EntryKind? {
        get {
            return EntryKind(rawValue: rawKind)
        }
        set {
            rawKind = newValue?.rawValue ?? ""
        }
    }

}
