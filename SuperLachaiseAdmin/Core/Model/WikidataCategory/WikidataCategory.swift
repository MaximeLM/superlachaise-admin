//
//  WikidataCategory.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 03/03/2018.
//

import Foundation
import RealmSwift

final class WikidataCategory: Object {

    @objc dynamic var id = ""

    @objc dynamic var name: String?

    let categories = List<Category>()
    let wikidataEntries = LinkingObjects(fromType: WikidataEntry.self, property: "wikidataCategories")

    override static func primaryKey() -> String {
        return "id"
    }

    override var description: String {
        return [name, id]
            .compactMap { $0 }
            .joined(separator: " - ")
    }

}
