//
//  SuperLachaisePOI.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 03/12/2017.
//

import Foundation
import RealmSwift

final class SuperLachaisePOI: Object {

    @objc dynamic var wikidataId: String = ""

    @objc dynamic var openStreetMapElement: OpenStreetMapElement?
    @objc dynamic var primaryWikidataEntry: WikidataEntry?
    let secondayWikidataEntries = List<WikidataEntry>()

    @objc dynamic var name: String?

    @objc dynamic var deleted = false

    override static func primaryKey() -> String {
        return "wikidataId"
    }

    override var description: String {
        return [name, wikidataId]
            .flatMap { $0 }
            .joined(separator: " - ")
    }

}
