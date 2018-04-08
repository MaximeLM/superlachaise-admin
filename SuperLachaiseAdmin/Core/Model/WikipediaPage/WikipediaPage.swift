//
//  WikipediaPage.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 21/12/2017.
//

import Foundation
import RealmSwift

final class WikipediaPage: Object {

    // Serialized as language/title
    @objc dynamic var rawWikipediaId = ""

    @objc dynamic var name: String?

    @objc dynamic var defaultSort: String?
    @objc dynamic var extract: String?

    override static func primaryKey() -> String {
        return "rawWikipediaId"
    }

    override var description: String {
        return rawWikipediaId
    }

}
