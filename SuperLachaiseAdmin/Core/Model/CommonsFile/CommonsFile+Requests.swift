//
//  CommonsFile+Requests.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 02/03/2018.
//

import Foundation
import RealmSwift

extension CommonsFile {

    static func all() -> (Realm) -> Results<CommonsFile> {
        return { realm in
            realm.objects(CommonsFile.self)
        }
    }

    static func find(commonsId: String) -> (Realm) -> CommonsFile? {
        return { realm in
            realm.object(ofType: CommonsFile.self, forPrimaryKey: commonsId)
        }
    }

    static func findOrCreate(commonsId: String) -> (Realm) -> CommonsFile {
        return { realm in
            if let commonsFile = find(commonsId: commonsId)(realm) {
                return commonsFile
            } else {
                return realm.create(CommonsFile.self,
                                    value: ["commonsId": commonsId],
                                    update: false)
            }
        }
    }

}
