//
//  Listable.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 02/12/2017.
//

import CoreData
import Foundation

protocol CoreDataListable {

    static func list(filter: String, context: NSManagedObjectContext) -> [Self]

}
