//
//  WikidataLocalizedEntry+Protocols.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 28/03/2018.
//

import Foundation
import RealmSwift

extension WikidataLocalizedEntry: Deletable {

    // MARK: Deletable

    func delete() {
        realm?.delete(self)
    }

    static func deleted() -> (Realm) -> Results<WikidataLocalizedEntry> {
        return { realm in
            realm.objects(WikidataLocalizedEntry.self).filter("isDeleted == true")
        }
    }

}
