//
//  CoreDataObjectKey.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 07/11/2018.
//

import CoreData
import Foundation

protocol CoreDataObjectKey {

    associatedtype CoreDataObject: NSManagedObject

    var coreDataAttributes: [String: Any] { get }

}
