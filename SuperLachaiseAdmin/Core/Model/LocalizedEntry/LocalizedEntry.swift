//
//  LocalizedEntry.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 25/03/2018.
//

import Foundation
import RealmSwift

final class LocalizedEntry: Object {

    @objc dynamic var language: String = ""

    @objc dynamic var name: String?
    @objc dynamic var summary: String?
    @objc dynamic var wikipediaExtract: String?

    @objc dynamic var entry: Entry?

    override var description: String {
        return [name, language]
            .flatMap { $0 }
            .joined(separator: " - ")
    }

}
