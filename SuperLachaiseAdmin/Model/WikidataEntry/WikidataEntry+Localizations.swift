//
//  WikidataEntry+Localizations.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 12/12/2017.
//

import Foundation
import RealmSwift

extension WikidataEntry {

    func findOrCreateLocalization(language: String, realm: Realm) -> WikidataLocalizedEntry {
        if let localization = localizations.first(where: { $0.language == language }) {
            return localization
        } else {
            let localization = realm.create(WikidataLocalizedEntry.self)
            localization.wikidataEntry = self
            localization.language = language
            return localization
        }
    }

}
