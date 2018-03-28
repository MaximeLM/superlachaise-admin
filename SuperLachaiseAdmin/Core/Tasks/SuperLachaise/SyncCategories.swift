//
//  SyncCategories.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 28/03/2018.
//

import Foundation

import Foundation
import RealmSwift
import RxSwift

final class SyncCategories: Task {

    enum Scope: CustomStringConvertible {

        case all
        case single(id: String)

        var description: String {
            switch self {
            case .all:
                return "all"
            case let .single(id):
                return id
            }
        }

    }

    let scope: Scope
    let config: SuperLachaiseConfig

    init(scope: Scope, config: SuperLachaiseConfig) {
        self.scope = scope
        self.config = config
    }

    var description: String {
        return "\(type(of: self)) (\(scope.description))"
    }

    // MARK: Execution

    func asSingle() -> Single<Void> {
        return Realm.async(dispatchQueue: realmDispatchQueue) { realm in
            try realm.write {
                self.prepareOrphans(realm: realm)
                self.syncCategories(realm: realm)
                self.cleanupOrphans(realm: realm)
            }
        }
    }

    // MARK: Private properties

    private let realmDispatchQueue = DispatchQueue(label: "SyncCategories.realm")

}

private extension SyncCategories {

    func prepareOrphans(realm: Realm) {
        switch self.scope {
        case .all:
            Category.all()(realm).setValue(true, forKey: "isDeleted")
        case .single:
            break
        }
    }

    func syncCategories(realm: Realm) {
        var configCategories = config.categories
        switch scope {
        case .all:
            break
        case let .single(id):
            configCategories = configCategories.filter { $0.id == id }
        }
        configCategories.forEach { self.syncCategory(configCategory: $0, realm: realm) }
    }

    func syncCategory(configCategory: ConfigCategory, realm: Realm) {
        let category = Category.findOrCreate(id: configCategory.id)(realm)
        category.isDeleted = false

        category.localizations.setValue(true, forKey: "isDeleted")
        for (language, name) in configCategory.name {
            let localization = category.findOrCreateLocalization(language: language)(realm)
            localization.isDeleted = false
            localization.name = name
        }

        let wikidataCategories = configCategory.wikidataCategoriesIds.flatMap { wikidataId -> WikidataCategory? in
            guard let wikidataCategory = WikidataCategory.find(wikidataId: wikidataId)(realm) else {
                Logger.warning("\(WikidataCategory.self) \(wikidataId) does not exist")
                return nil
            }
            return wikidataCategory
        }
        category.setWikidataCategories(wikidataCategories)
    }

    func cleanupOrphans(realm: Realm) {
        let orphans = realm.objects(Category.self).filter("isDeleted == true")
        orphans.forEach { $0.setWikidataCategories([]) }
    }

}

private extension Category {

    func setWikidataCategories(_ newWikidataCategories: [WikidataCategory]) {
        for wikidataCategory in wikidataCategories {
            if let index = wikidataCategory.categories.index(of: self) {
                wikidataCategory.categories.remove(at: index)
            }
        }
        for wikidataCategory in newWikidataCategories {
            if !wikidataCategory.categories.contains(self) {
                wikidataCategory.categories.append(self)
            }
        }
    }

}
