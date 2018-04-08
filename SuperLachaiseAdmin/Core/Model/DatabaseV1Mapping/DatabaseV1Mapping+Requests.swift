//
//  DatabaseV1Mapping+Requests.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 30/03/2018.
//

import Foundation
import RealmSwift

extension DatabaseV1Mapping {

    static func all() -> (Realm) -> Results<DatabaseV1Mapping> {
        return { realm in
            realm.objects(DatabaseV1Mapping.self)
        }
    }

    static func find(id: Int) -> (Realm) -> DatabaseV1Mapping? {
        return { realm in
            realm.object(ofType: DatabaseV1Mapping.self, forPrimaryKey: id)
        }
    }

    static func findOrCreate(id: Int) -> (Realm) -> DatabaseV1Mapping {
        return { realm in
            if let databaseV1Mapping = find(id: id)(realm) {
                return databaseV1Mapping
            } else {
                return realm.create(DatabaseV1Mapping.self,
                                    value: ["id": id],
                                    update: false)
            }
        }
    }

}
