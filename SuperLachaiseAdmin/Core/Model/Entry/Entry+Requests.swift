//
//  Entry+Requests.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 25/03/2018.
//

import Foundation
import RealmSwift

extension Entry {

    static func all() -> (Realm) -> Results<Entry> {
        return { realm in
            realm.objects(Entry.self)
        }
    }

    static func find(wikidataId: String) -> (Realm) -> Entry? {
        return { realm in
            realm.object(ofType: Entry.self, forPrimaryKey: wikidataId)
        }
    }

    static func findOrCreate(wikidataId: String) -> (Realm) -> Entry {
        return { realm in
            if let entry = find(wikidataId: wikidataId)(realm) {
                return entry
            } else {
                return realm.create(Entry.self, value: ["wikidataId": wikidataId], update: false)
            }
        }
    }

    // MARK: Localizations

    func localization(language: String) -> LocalizedEntry? {
        return localizations.first { $0.language == language }
    }

    func findOrCreateLocalization(language: String) -> (Realm) -> LocalizedEntry {
        return { realm in
            if let localization = self.localization(language: language) {
                return localization
            } else {
                let localization = realm.create(LocalizedEntry.self)
                localization.entry = self
                localization.language = language
                return localization
            }
        }
    }

}
