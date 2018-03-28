//
//  LocalizedEntry+Protocols.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 28/03/2018.
//

import Foundation
import RealmSwift

extension LocalizedEntry: Deletable {

    // MARK: Deletable

    func delete() {
        realm?.delete(self)
    }

    static func deleted() -> (Realm) -> Results<LocalizedEntry> {
        return { realm in
            realm.objects(LocalizedEntry.self).filter("isDeleted == true")
        }
    }

}
