//
//  WikidataEntry+Nature.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 12/12/2017.
//

import Foundation

enum WikidataEntryNature: String {
    case person, grave, monument
}

extension WikidataEntry {

    var nature: WikidataEntryNature? {
        get {
            return WikidataEntryNature(rawValue: rawNature)
        }
        set {
            rawNature = newValue?.rawValue ?? ""
        }
    }

}
