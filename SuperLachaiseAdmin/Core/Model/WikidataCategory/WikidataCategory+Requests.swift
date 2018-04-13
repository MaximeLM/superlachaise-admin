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

    static func find(id: String) -> (Realm) -> WikidataCategory? {
        return { realm in
            realm.object(ofType: WikidataCategory.self, forPrimaryKey: id)
        }
    }

    static func findOrCreate(id: String) -> (Realm) -> WikidataCategory {
        return { realm in
            if let wikidataCategory = find(id: id)(realm) {
                return wikidataCategory
            } else {
                return realm.create(WikidataCategory.self, value: ["id": id], update: false)
            }
        }
    }

}
