//
//  WikipediaPage.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 21/12/2017.
//

import Foundation
import RealmSwift

final class WikipediaPage: Object {

    // "language/title"
    @objc dynamic var id = ""

    @objc dynamic var name: String?

    @objc dynamic var defaultSort: String?
    @objc dynamic var extract: String?

    override static func primaryKey() -> String {
        return "id"
    }

    override var description: String {
        return (wikipediaId.map { [$0.title, $0.language] } ?? [])
            .joined(separator: " - ")
    }

}
