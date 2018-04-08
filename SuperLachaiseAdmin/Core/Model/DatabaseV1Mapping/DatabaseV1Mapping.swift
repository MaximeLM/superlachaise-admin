//
//  DatabaseV1Mapping.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 30/03/2018.
//

import Foundation
import RealmSwift

final class DatabaseV1Mapping: Object {

    @objc dynamic var monumentId: Int = 0

    @objc dynamic var pointOfInterest: PointOfInterest?

    override static func primaryKey() -> String {
        return "monumentId"
    }

    override var description: String {
        return "\(monumentId) → \(pointOfInterest?.description ?? "nil")"
    }

}
