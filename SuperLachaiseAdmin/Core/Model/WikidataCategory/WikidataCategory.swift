//
//  WikidataCategory.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 03/03/2018.
//

import Foundation
import RealmSwift

final class WikidataCategory: Object {

    @objc dynamic var wikidataId = ""

    @objc dynamic var name: String?

    let categories = List<Category>()

    override static func primaryKey() -> String {
        return "wikidataId"
    }

    override var description: String {
        return [name, wikidataId]
            .compactMap { $0 }
            .joined(separator: " - ")
    }

}
