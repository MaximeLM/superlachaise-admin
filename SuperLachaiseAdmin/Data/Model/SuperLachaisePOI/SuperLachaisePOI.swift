//
//  SuperLachaisePOI.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 03/12/2017.
//

import Foundation
import RealmSwift

final class SuperLachaisePOI: Object {

    // MARK: Properties

    @objc dynamic var wikidataId: String = ""

    @objc dynamic var openStreetMapElement: OpenStreetMapElement?

    @objc dynamic var name: String?

    @objc dynamic var toBeDeleted = false

    override static func primaryKey() -> String {
        return "wikidataId"
    }

    override var description: String {
        return [name, wikidataId]
            .flatMap { $0 }
            .joined(separator: " - ")
    }

}
