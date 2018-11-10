//
//  KeyedObject.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 07/11/2018.
//

import CoreData
import Foundation

protocol KeyedObject {

    associatedtype Key

    static func attributes(key: Key) -> [String: Any]

}
