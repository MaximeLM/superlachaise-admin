//
//  Realm+Write.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 12/12/2017.
//

import Foundation
import RealmSwift

extension Realm {

    func write<E>(block: () throws -> E) throws -> E {
        let result: E
        beginWrite()
        do {
            result = try block()
        } catch let error {
            if isInWriteTransaction { cancelWrite() }
            throw error
        }
        if isInWriteTransaction { try commitWrite() }
        return result
    }

}
