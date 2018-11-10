//
//  Listable.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 02/12/2017.
//

import CoreData
import Foundation

protocol Listable {

    static func list(filter: String, context: NSManagedObjectContext) -> [Self]

}
