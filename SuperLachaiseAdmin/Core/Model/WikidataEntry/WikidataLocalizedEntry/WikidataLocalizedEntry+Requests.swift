//
//  WikidataLocalizedEntry+Requests.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 22/12/2017.
//

import Foundation
import RealmSwift

extension WikidataLocalizedEntry {

    static func all() -> (Realm) -> Results<WikidataLocalizedEntry> {
        return { realm in
            realm.objects(WikidataLocalizedEntry.self).filter("wikidataEntry.isDeleted == false && isDeleted == false")
        }
    }

}
