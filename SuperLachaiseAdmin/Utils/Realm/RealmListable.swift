//
//  RealmListable.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 02/12/2017.
//

import Foundation
import RealmSwift

protocol RealmListable: RealmCollectionValue {

    static func list() -> (Realm) -> Results<Self>

}
