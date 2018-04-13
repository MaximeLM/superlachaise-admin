//
//  DatabaseV1Mapping.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 30/03/2018.
//

import Foundation
import RealmSwift

final class DatabaseV1Mapping: Object {

    // monument ID
    @objc dynamic var id: Int = 0

    @objc dynamic var pointOfInterest: PointOfInterest?

    override static func primaryKey() -> String {
        return "id"
    }

    override var description: String {
        return "\(id) → \(pointOfInterest?.description ?? "nil")"
    }

}
