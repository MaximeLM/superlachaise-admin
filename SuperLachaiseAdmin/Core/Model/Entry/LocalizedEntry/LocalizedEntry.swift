//
//  LocalizedEntry.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 25/03/2018.
//

import Foundation
import RealmSwift

final class LocalizedEntry: Object {

    @objc dynamic var language = ""

    @objc dynamic var name = ""
    @objc dynamic var summary = ""
    @objc dynamic var defaultSort = ""

    @objc dynamic var wikipediaTitle: String?
    @objc dynamic var wikipediaExtract: String?

    @objc dynamic var entry: Entry?

    @objc dynamic var isDeleted = false

    override var description: String {
        return [name, language]
            .compactMap { $0 }
            .joined(separator: " - ")
    }

}
