//
//  Listable.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 02/12/2017.
//

import Foundation
import RealmSwift

protocol Listable: RealmCollectionValue {

    static func list(filter: String) -> (Realm) -> Results<Self>

}

protocol CoreDataListable {

    static func list(filter: String, context: NSManagedObjectContext) -> [Self]

}
