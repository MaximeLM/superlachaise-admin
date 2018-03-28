//
//  LocalizedCategory.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 28/03/2018.
//

import Foundation
import RealmSwift

final class LocalizedCategory: Object {

    @objc dynamic var language = ""

    @objc dynamic var name = ""

    @objc dynamic var category: Category?

    override var description: String {
        return [name, language]
            .flatMap { $0 }
            .joined(separator: " - ")
    }

}
