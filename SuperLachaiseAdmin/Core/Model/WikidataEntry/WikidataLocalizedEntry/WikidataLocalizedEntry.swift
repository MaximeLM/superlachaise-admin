//
//  WikidataLocalizedEntry.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 12/12/2017.
//

import Foundation
import RealmSwift

final class WikidataLocalizedEntry: Object {

    @objc dynamic var language = ""

    @objc dynamic var name: String?
    @objc dynamic var summary: String?
    @objc dynamic var wikipediaPage: WikipediaPage?

    @objc dynamic var wikidataEntry: WikidataEntry?

    @objc dynamic var isDeleted = false

    override var description: String {
        return [name, language]
            .flatMap { $0 }
            .joined(separator: " - ")
    }

}
