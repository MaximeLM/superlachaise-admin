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
        var categoriesIds: [String]
        switch scope {
        case .all:
            categoriesIds = Category.all()(realm).map { $0.id }
            categoriesIds.append(contentsOf: config.categories.map { $0.id })
            categoriesIds = categoriesIds.uniqueValues()
        case let .single(id):
            categoriesIds = [id]
        }
        return categoriesIds.compactMap { self.syncCategory(id: $0, realm: realm) }
    }

    func syncCategory(id: String, realm: Realm) -> Category? {
        guard let configCategory = config.categories.first(where: { $0.id == id }) else {
            Logger.warning("No config for \(Category.self) id \(id)")
            return nil
        }
        let category = Category.findOrCreate(id: id)(realm)

        for (language, name) in configCategory.name {
            let localization = category.findOrCreateLocalization(language: language)(realm)
            localization.name = name
        }

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
