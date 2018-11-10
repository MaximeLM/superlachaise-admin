//
//  CoreDataCommonsFile.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 10/11/2018.
//

import CoreData
import Foundation

final class CoreDataCommonsFile: NSManagedObject {

    // title without "File:"
    @NSManaged var id: String

    @NSManaged var width: Float
    @NSManaged var height: Float

    @NSManaged var rawImageURL: String
    @NSManaged var thumbnailURLTemplate: String // Replace {{width}} with the desired width

    @NSManaged var author: String?
    @NSManaged var license: String?

    @NSManaged var imageOf: Set<CoreDataWikidataEntry>
    @NSManaged var imageOfGraveOf: Set<CoreDataWikidataEntry>

    @NSManaged var pointsOfInterest: Set<CoreDataPointOfInterest>

    override var description: String {
        return id
    }

}
