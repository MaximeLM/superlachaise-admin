//
//  OpenStreetMapElement+Requests.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 12/12/2017.
//

import Foundation
import RealmSwift

extension OpenStreetMapElement {

    static func all() -> (Realm) -> Results<OpenStreetMapElement> {
        return { realm in
            realm.objects(OpenStreetMapElement.self).filter("isDeleted == false")
        }
    }

    static func find(openStreetMapId: OpenStreetMapId) -> (Realm) -> OpenStreetMapElement? {
        return { realm in
            realm.object(ofType: OpenStreetMapElement.self, forPrimaryKey: openStreetMapId.rawValue)
        }
    }

    static func findOrCreate(openStreetMapId: OpenStreetMapId) -> (Realm) -> OpenStreetMapElement {
        return { realm in
            if let openStreetMapElement = find(openStreetMapId: openStreetMapId)(realm) {
                return openStreetMapElement
            } else {
                return realm.create(OpenStreetMapElement.self,
                                    value: ["rawOpenStreetMapId": openStreetMapId.rawValue],
                                    update: false)
            }
        }
    }

}
