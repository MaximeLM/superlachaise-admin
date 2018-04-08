//
//  LocalizedEntry+Protocols.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 28/03/2018.
//

import Foundation
import RealmSwift

extension LocalizedEntry: Deletable {

    // MARK: Deletable

    func delete() {
        realm?.delete(self)
    }

}
