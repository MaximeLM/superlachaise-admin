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

    override static func primaryKey() -> String {
        return "id"
    }

    override var description: String {
        return id
    }

}
