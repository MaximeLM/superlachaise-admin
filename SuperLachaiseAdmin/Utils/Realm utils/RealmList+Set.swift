//
//  RealmList+Set.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 13/12/2017.
//

import Foundation
import RealmSwift

extension List {

    func set(_ values: [Element]) {
        removeAll()
        append(objectsIn: values)
    }

}
