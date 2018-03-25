//
//  SuperLachaiseEntry+Requests.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 25/03/2018.
//

import Foundation
import RealmSwift

extension SuperLachaiseEntry {

    static func all() -> (Realm) -> Results<SuperLachaiseEntry> {
        return { realm in
            realm.objects(SuperLachaiseEntry.self).filter("deleted == false")
        }
    }

    static func find(wikidataId: String) -> (Realm) -> SuperLachaiseEntry? {
        return { realm in
            realm.object(ofType: SuperLachaiseEntry.self, forPrimaryKey: wikidataId)
        }
    }

    static func findOrCreate(wikidataId: String) -> (Realm) -> SuperLachaiseEntry {
        return { realm in
            if let superLachaiseEntry = find(wikidataId: wikidataId)(realm) {
                return superLachaiseEntry
            } else {
                return realm.create(SuperLachaiseEntry.self, value: ["wikidataId": wikidataId], update: false)
            }
        }
    }

    // MARK: Localizations

    func localization(language: String) -> SuperLachaiseLocalizedEntry? {
        return localizations.first { $0.language == language }
    }

    func findOrCreateLocalization(language: String) -> (Realm) -> SuperLachaiseLocalizedEntry {
        return { realm in
            if let localization = self.localization(language: language) {
                return localization
            } else {
                let localization = realm.create(SuperLachaiseLocalizedEntry.self)
                localization.superLachaiseEntry = self
                localization.language = language
                return localization
            }
        }
    }

}
