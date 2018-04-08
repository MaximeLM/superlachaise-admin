//
//  SyncCategories.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 28/03/2018.
//

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
                let categories = self.syncCategories(realm: realm)
                try self.deleteOrphans(fetchedCategoryIds: categories.map { $0.id }, realm: realm)
            }
        }
    }

    // MARK: Private properties

    private let realmDispatchQueue = DispatchQueue(label: "SyncCategories.realm")

}

private extension SyncCategories {

    func syncCategories(realm: Realm) -> [Category] {
        var configCategories = config.categories
        switch scope {
        case .all:
            break
        case let .single(id):
            configCategories = configCategories.filter { $0.id == id }
        }
        return configCategories.map { self.syncCategory(configCategory: $0, realm: realm) }
    }

    func syncCategory(configCategory: ConfigCategory, realm: Realm) -> Category {
        let category = Category.findOrCreate(id: configCategory.id)(realm)

        for (language, name) in configCategory.name {
            let localization = category.findOrCreateLocalization(language: language)(realm)
            localization.name = name
        }

        let wikidataCategories = configCategory.wikidataCategoriesIds.compactMap { wikidataId -> WikidataCategory? in
            guard let wikidataCategory = WikidataCategory.find(wikidataId: wikidataId)(realm) else {
                Logger.warning("\(WikidataCategory.self) \(wikidataId) does not exist")
                return nil
            }
            return wikidataCategory
        }
        category.setWikidataCategories(wikidataCategories, realm: realm)

        return category
    }

    // MARK: Orphans

    func deleteOrphans(fetchedCategoryIds: [String], realm: Realm) throws {
        // List existing objects
        var orphanedObjects: Set<Category>
        switch scope {
        case .all:
            orphanedObjects = Set(Category.all()(realm))
        case .single:
            orphanedObjects = Set()
        }

        orphanedObjects = orphanedObjects.filter { !fetchedCategoryIds.contains($0.id) }

        if !orphanedObjects.isEmpty {
            Logger.info("Deleting \(orphanedObjects.count) \(Category.self)(s)")
            orphanedObjects.forEach { $0.delete() }
        }
    }

}

private extension Category {

    func setWikidataCategories(_ newWikidataCategories: [WikidataCategory], realm: Realm) {
        for wikidataCategory in realm.objects(WikidataCategory.self).filter("ANY categories == %@", self) {
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
