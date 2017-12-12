//
//  SuperLachaise+Requests.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 12/12/2017.
//

import Foundation
import RealmSwift

extension SuperLachaisePOI {

    static func all() -> (Realm) -> Results<SuperLachaisePOI> {
        return { realm in
            realm.objects(SuperLachaisePOI.self).filter("deleted == false")
        }
    }

    static func find(wikidataId: String) -> (Realm) -> SuperLachaisePOI? {
        return { realm in
            realm.object(ofType: SuperLachaisePOI.self, forPrimaryKey: wikidataId)
        }
    }

    static func findOrCreate(wikidataId: String) -> (Realm) -> SuperLachaisePOI {
        return { realm in
            if let superLachaisePOI = find(wikidataId: wikidataId)(realm) {
                return superLachaisePOI
            } else {
                return realm.create(SuperLachaisePOI.self, value: ["wikidataId": wikidataId], update: false)
            }
        }
    }

}
