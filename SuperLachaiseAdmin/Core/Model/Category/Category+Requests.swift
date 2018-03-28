//
//  Category+Requests.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 28/03/2018.
//

import Foundation
import RealmSwift

extension Category {

    static func all() -> (Realm) -> Results<Category> {
        return { realm in
            realm.objects(Category.self).filter("isDeleted == false")
        }
    }

    static func find(id: String) -> (Realm) -> Category? {
        return { realm in
            realm.object(ofType: Category.self, forPrimaryKey: id)
        }
    }

    static func findOrCreate(id: String) -> (Realm) -> Category {
        return { realm in
            if let category = find(id: id)(realm) {
                return category
            } else {
                return realm.create(Category.self, value: ["id": id], update: false)
            }
        }
    }

    // MARK: Localizations

    func localization(language: String) -> LocalizedCategory? {
        return localizations.first { $0.language == language }
    }

    func findOrCreateLocalization(language: String) -> (Realm) -> LocalizedCategory {
        return { realm in
            if let localization = self.localization(language: language) {
                return localization
            } else {
                let localization = realm.create(LocalizedCategory.self)
                localization.category = self
                localization.language = language
                return localization
            }
        }
    }

}
