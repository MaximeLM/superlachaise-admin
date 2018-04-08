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

    static func find(id: String) -> (Realm) -> CommonsFile? {
        return { realm in
            realm.object(ofType: CommonsFile.self, forPrimaryKey: id)
        }
    }

    static func findOrCreate(id: String) -> (Realm) -> CommonsFile {
        return { realm in
            if let commonsFile = find(id: id)(realm) {
                return commonsFile
            } else {
                return realm.create(CommonsFile.self,
                                    value: ["id": id],
                                    update: false)
            }
        }
    }

}
