//
//  LocalizedCategory+Protocols.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 28/03/2018.
//

import Foundation
import RealmSwift

extension LocalizedCategory: Deletable {

    // MARK: Deletable

    func delete() {
        realm?.delete(self)
    }

    static func deleted() -> (Realm) -> Results<LocalizedCategory> {
        return { realm in
            realm.objects(LocalizedCategory.self).filter("isDeleted == true")
        }
    }

}
