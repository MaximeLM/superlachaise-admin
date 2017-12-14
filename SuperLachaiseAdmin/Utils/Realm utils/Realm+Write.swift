//
//  Realm+Write.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 14/12/2017.
//

import Foundation
import RealmSwift

extension Realm {

    func write<T>(_ block: (() throws -> T)) throws -> T {
        let result: T
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
