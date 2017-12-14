//
//  RealmList+Replace.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 13/12/2017.
//

import Foundation
import RealmSwift

extension List {

    func replaceAll(objects: [Element]) {
        removeAll()
        append(objectsIn: objects)
    }

}
