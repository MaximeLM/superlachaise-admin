//
//  WikipediaPage+Requests.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 21/12/2017.
//

import Foundation
import RealmSwift

extension WikipediaPage {

    static func all() -> (Realm) -> Results<WikipediaPage> {
        return { realm in
            realm.objects(WikipediaPage.self).filter("isDeleted == false")
        }
    }

    static func find(wikipediaId: WikipediaId) -> (Realm) -> WikipediaPage? {
        return { realm in
            realm.object(ofType: WikipediaPage.self, forPrimaryKey: wikipediaId.rawValue)
        }
    }

    static func findOrCreate(wikipediaId: WikipediaId) -> (Realm) -> WikipediaPage {
        return { realm in
            if let wikipediaPage = find(wikipediaId: wikipediaId)(realm) {
                return wikipediaPage
            } else {
                return realm.create(WikipediaPage.self,
                                    value: ["rawWikipediaId": wikipediaId.rawValue],
                                    update: false)
            }
        }
    }

}
