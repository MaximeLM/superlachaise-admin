//
//  CommonsCategory.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 20/02/2018.
//

import Foundation
import RealmSwift

final class CommonsCategory: Object {

    // Title without "Category:"
    @objc dynamic var commonsId = ""

    @objc dynamic var defaultSort: String?

    @objc dynamic var mainCommonsFileId: String?
    let commonsFilesIds = List<String>()

    @objc dynamic var deleted = false

    override static func primaryKey() -> String {
        return "commonsId"
    }

    override var description: String {
        return commonsId
    }

}
