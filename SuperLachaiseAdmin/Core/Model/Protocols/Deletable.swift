//
//  Deletable.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 29/11/2017.
//

import Foundation
import RealmSwift

protocol Deletable: RealmCollectionValue {

    func delete()

}
