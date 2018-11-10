//
//  DatabaseV1Mapping.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 10/11/2018.
//

import CoreData
import Foundation

final class DatabaseV1Mapping: NSManagedObject {

    // monument ID
    @NSManaged var id: Int32

    @NSManaged var pointOfInterest: PointOfInterest?

    override var description: String {
        return "\(id) → \(pointOfInterest?.description ?? "nil")"
    }

}
