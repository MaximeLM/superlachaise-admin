//
//  WikidataLocalizedEntry.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 12/12/2017.
//

import Foundation
import RealmSwift

final class WikidataLocalizedEntry: Object {

    @objc dynamic var language: String = ""

    @objc dynamic var name: String?
    @objc dynamic var summary: String?
    @objc dynamic var wikipediaTitle: String?

    @objc dynamic var wikidataEntry: WikidataEntry?

    override var description: String {
        return [name, language]
            .flatMap { $0 }
            .joined(separator: " - ")
    }

}
