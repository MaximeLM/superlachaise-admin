//
//  CoreDataDatabaseV1Mapping.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 10/11/2018.
//

import CoreData
import Foundation

final class CoreDataDatabaseV1Mapping: NSManagedObject {

    // monument ID
    @NSManaged var id: Int

    @NSManaged var pointOfInterest: CoreDataPointOfInterest?

    override var description: String {
        return "\(id) → \(pointOfInterest?.description ?? "nil")"
    }

}
