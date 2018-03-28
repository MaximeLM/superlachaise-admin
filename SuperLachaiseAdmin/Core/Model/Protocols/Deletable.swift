//
//  Deletable.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 29/11/2017.
//

import Foundation
import RealmSwift

protocol Deletable: RealmCollectionValue {

    var isDeleted: Bool { get set }

    func delete()

    static func deleted() -> (Realm) -> Results<Self>

}
