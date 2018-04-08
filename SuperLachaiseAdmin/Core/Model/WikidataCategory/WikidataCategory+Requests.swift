//
//  WikidataCategory+Requests.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 03/03/2018.
//

import Foundation
import RealmSwift

extension WikidataCategory {

    static func all() -> (Realm) -> Results<WikidataCategory> {
        return { realm in
            realm.objects(WikidataCategory.self)
        }
    }

    static func find(wikidataId: String) -> (Realm) -> WikidataCategory? {
        return { realm in
            realm.object(ofType: WikidataCategory.self, forPrimaryKey: wikidataId)
        }
    }

    static func findOrCreate(wikidataId: String) -> (Realm) -> WikidataCategory {
        return { realm in
            if let wikidataCategory = find(wikidataId: wikidataId)(realm) {
                return wikidataCategory
            } else {
                return realm.create(WikidataCategory.self, value: ["wikidataId": wikidataId], update: false)
            }
        }
    }

}
