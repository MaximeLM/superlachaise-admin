//
//  RealmListable.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 02/12/2017.
//

import Foundation
import RealmSwift

protocol RealmListable: RealmCollectionValue, RealmIdentifiable {

    static func list(filter: String) -> (Realm) -> Results<Self>

}
