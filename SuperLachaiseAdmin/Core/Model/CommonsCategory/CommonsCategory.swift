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
    @objc dynamic var commonsCategoryId = ""

    @objc dynamic var defaultSort: String?

    @objc dynamic var mainCommonsFileId: String?

    @objc dynamic var deleted = false

    override static func primaryKey() -> String {
        return "commonsCategoryId"
    }

    override var description: String {
        return commonsCategoryId
    }

}
