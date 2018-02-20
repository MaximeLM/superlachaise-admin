//
//  CommonsCategory.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 20/02/2018.
//

import Foundation
import RealmSwift

final class CommonsCategory: Object {

    // Without "Category:"
    @objc dynamic var name = ""

    @objc dynamic var defaultSort: String?

    @objc dynamic var mainCommonsFileName: String?
    let commonsFilesNames = List<String>()

    @objc dynamic var deleted = false

    override static func primaryKey() -> String {
        return "name"
    }

    override var description: String {
        return name
    }

}
