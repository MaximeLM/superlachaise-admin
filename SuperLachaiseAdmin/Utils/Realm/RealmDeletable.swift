//
//  RealmDeletable.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 29/11/2017.
//

import Foundation

protocol RealmDeletable {

    var toBeDeleted: Bool { get set }

    func delete()

}
