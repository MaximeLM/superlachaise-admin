//
//  WikidataEntry+Kind.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 12/12/2017.
//

import Foundation

extension WikidataEntry {

    var kind: EntryKind? {
        get {
            return EntryKind(rawValue: rawKind)
        }
        set {
            rawKind = newValue?.rawValue ?? ""
        }
    }

}
