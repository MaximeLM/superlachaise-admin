//
//  CommonsCategory+Requests.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 20/02/2018.
//

import Foundation
import RealmSwift

extension CommonsCategory {

    static func all() -> (Realm) -> Results<CommonsCategory> {
        return { realm in
            realm.objects(CommonsCategory.self).filter("deleted == false")
        }
    }

    static func find(name: CommonsCategory) -> (Realm) -> CommonsCategory? {
        return { realm in
            realm.object(ofType: CommonsCategory.self, forPrimaryKey: name)
        }
    }

    static func findOrCreate(name: CommonsCategory) -> (Realm) -> CommonsCategory {
        return { realm in
            if let commonsCategory = find(name: name)(realm) {
                return commonsCategory
            } else {
                return realm.create(CommonsCategory.self,
                                    value: ["name": name],
                                    update: false)
            }
        }
    }

}
