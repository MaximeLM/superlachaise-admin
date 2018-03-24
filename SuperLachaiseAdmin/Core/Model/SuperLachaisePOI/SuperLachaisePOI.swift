//
//  SuperLachaisePOI.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 03/12/2017.
//

import Foundation
import RealmSwift

final class SuperLachaisePOI: Object {

    // Serialized as language/wikidataId
    @objc dynamic var rawSuperLachaiseId: String = ""

    @objc dynamic var latitude: Double = 0
    @objc dynamic var longitude: Double = 0

    @objc dynamic var deleted = false

    override static func primaryKey() -> String {
        return "rawSuperLachaiseId"
    }

    override var description: String {
        return rawSuperLachaiseId
    }

}
