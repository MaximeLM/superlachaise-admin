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

    static func find(commonsCategoryId: String) -> (Realm) -> CommonsCategory? {
        return { realm in
            realm.object(ofType: CommonsCategory.self, forPrimaryKey: commonsCategoryId)
        }
    }

    static func findOrCreate(commonsCategoryId: String) -> (Realm) -> CommonsCategory {
        return { realm in
            if let commonsCategory = find(commonsCategoryId: commonsCategoryId)(realm) {
                return commonsCategory
            } else {
                return realm.create(CommonsCategory.self,
                                    value: ["commonsCategoryId": commonsCategoryId],
                                    update: false)
            }
        }
    }

}
