//
//  WikidataCategory.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 03/03/2018.
//

import Foundation
import RealmSwift

final class WikidataCategory: Object {

    @objc dynamic var wikidataId: String = ""

    @objc dynamic var name: String?

    @objc dynamic var deleted = false

    override static func primaryKey() -> String {
        return "wikidataId"
    }

    override var description: String {
        return [name, wikidataId]
            .flatMap { $0 }
            .joined(separator: " - ")
    }

}
