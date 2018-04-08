//
//  PointOfInterest+Requests.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 12/12/2017.
//

import Foundation
import RealmSwift

extension PointOfInterest {

    static func all() -> (Realm) -> Results<PointOfInterest> {
        return { realm in
            realm.objects(PointOfInterest.self)
        }
    }

    static func find(id: String) -> (Realm) -> PointOfInterest? {
        return { realm in
            realm.object(ofType: PointOfInterest.self, forPrimaryKey: id)
        }
    }

    static func findOrCreate(id: String) -> (Realm) -> PointOfInterest {
        return { realm in
            if let pointOfInterest = find(id: id)(realm) {
                return pointOfInterest
            } else {
                return realm.create(PointOfInterest.self,
                                    value: ["id": id],
                                    update: false)
            }
        }
    }

}
