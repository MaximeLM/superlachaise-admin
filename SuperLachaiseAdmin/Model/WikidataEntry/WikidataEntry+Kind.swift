//
//  WikidataEntry+Kind.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 12/12/2017.
//

import Foundation

enum WikidataEntryKind: String {
    case grave, graveOf, monument
}

extension WikidataEntry {

    var kind: WikidataEntryKind? {
        get {
            return WikidataEntryKind(rawValue: rawKind)
        }
        set {
            rawKind = newValue?.rawValue ?? ""
        }
    }

}
