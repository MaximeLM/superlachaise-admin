//
//  SuperLachaisePOI+Requests.swift
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

    static func find(superLachaiseId: SuperLachaiseId) -> (Realm) -> SuperLachaisePOI? {
        return { realm in
            realm.object(ofType: SuperLachaisePOI.self, forPrimaryKey: superLachaiseId.rawValue)
        }
    }

    static func findOrCreate(superLachaiseId: SuperLachaiseId) -> (Realm) -> SuperLachaisePOI {
        return { realm in
            if let superLachaisePOI = find(superLachaiseId: superLachaiseId)(realm) {
                return superLachaisePOI
            } else {
                return realm.create(SuperLachaisePOI.self,
                                    value: ["rawSuperLachaiseId": superLachaiseId.rawValue],
                                    update: false)
            }
        }
    }

}
