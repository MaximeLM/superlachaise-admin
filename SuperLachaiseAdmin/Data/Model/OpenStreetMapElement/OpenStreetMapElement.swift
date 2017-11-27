//
//  OpenStreetMapElement.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 28/11/2017.
//

import Foundation
import RealmSwift

final class OpenStreetMapElement: Object {

    // MARK: Properties

    @objc dynamic var rawElementType: String = ""
    @objc dynamic var numericId: Int64 = 0

    @objc dynamic var latitude: Double = 0
    @objc dynamic var longitude: Double = 0

    @objc dynamic var name: String?

    @objc dynamic var rawTags: Data?

    // MARK: Overrides

    override static func indexedProperties() -> [String] {
        return ["rawElementType", "numericId"]
    }

    override var description: String {
        return ["\(rawElementType)/\(numericId)", name]
            .flatMap { $0 }
            .joined(separator: " - ")
    }

}
