//
//  Category.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 28/03/2018.
//

import Foundation
import RealmSwift

final class Category: Object {

    @objc dynamic var id = ""

    let localizations = LinkingObjects(fromType: LocalizedCategory.self, property: "category")
    let wikidataCategories = LinkingObjects(fromType: WikidataCategory.self, property: "categories")

    @objc dynamic var deleted = false

    override static func primaryKey() -> String {
        return "id"
    }

    override var description: String {
        return id
    }

}
