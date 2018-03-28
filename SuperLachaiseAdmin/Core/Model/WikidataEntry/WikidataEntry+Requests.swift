//
//  wikidataEntry+Requests.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 12/12/2017.
//

import Foundation
import RealmSwift

extension WikidataEntry {

    static func all() -> (Realm) -> Results<WikidataEntry> {
        return { realm in
            realm.objects(WikidataEntry.self).filter("isDeleted == false")
        }
    }

    static func find(wikidataId: String) -> (Realm) -> WikidataEntry? {
        return { realm in
            realm.object(ofType: WikidataEntry.self, forPrimaryKey: wikidataId)
        }
    }

    static func findOrCreate(wikidataId: String) -> (Realm) -> WikidataEntry {
        return { realm in
            if let wikidataEntry = find(wikidataId: wikidataId)(realm) {
                return wikidataEntry
            } else {
                return realm.create(WikidataEntry.self, value: ["wikidataId": wikidataId], update: false)
            }
        }
    }

    // MARK: Localizations

    func localization(language: String) -> WikidataLocalizedEntry? {
        return localizations.first { $0.language == language }
    }

    func findOrCreateLocalization(language: String) -> (Realm) -> WikidataLocalizedEntry {
        return { realm in
            if let localization = self.localization(language: language) {
                return localization
            } else {
                let localization = realm.create(WikidataLocalizedEntry.self)
                localization.wikidataEntry = self
                localization.language = language
                return localization
            }
        }
    }

}
