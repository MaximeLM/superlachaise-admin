//
//  CommonsFile.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 02/03/2018.
//

import Foundation
import RealmSwift

final class CommonsFile: Object {

    // title without "File:"
    @objc dynamic var commonsId = ""

    @objc dynamic var author: String?
    @objc dynamic var license: String?

    @objc dynamic var width: Float = 0
    @objc dynamic var height: Float = 0

    @objc dynamic var rawImageURL = ""
    @objc dynamic var thumbnailURLTemplate = "" // Replace {{width}} with the desired width

    @objc dynamic var deleted = false

    override static func primaryKey() -> String {
        return "commonsId"
    }

    override var description: String {
        return commonsId
    }

}
