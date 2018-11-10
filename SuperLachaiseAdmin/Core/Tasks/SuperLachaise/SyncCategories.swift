//
//  SyncCategories.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 28/03/2018.
//

import CoreData
import Foundation
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
    let performInBackground: Single<NSManagedObjectContext>

    init(scope: Scope, config: SuperLachaiseConfig, performInBackground: Single<NSManagedObjectContext>) {
        self.scope = scope
        self.config = config
        self.performInBackground = performInBackground
    }

    var description: String {
        return "\(type(of: self)) (\(scope.description))"
    }

    // MARK: Execution

    func asSingle() -> Single<Void> {
        return performInBackground.map { context in
            try context.write {
                let categories = self.syncCategories(context: context)
                try self.deleteOrphans(fetchedCategoryIds: categories.map { $0.id }, context: context)
            }
        }
    }

}

private extension SyncCategories {

    func syncCategories(context: NSManagedObjectContext) -> [Category] {
        var categoriesIds: [String]
        switch scope {
        case .all:
            categoriesIds = context.objects(Category.self).fetch().map { $0.id }
            categoriesIds.append(contentsOf: config.categoriesNames.map { $0.key })
            categoriesIds = categoriesIds.uniqueValues()
        case let .single(id):
            categoriesIds = [id]
        }
        return categoriesIds.compactMap { self.syncCategory(id: $0, context: context) }
    }

    func syncCategory(id: String, context: NSManagedObjectContext) -> Category? {
        guard let categoryNames = config.categoriesNames.first(where: { $0.key == id }) else {
            Logger.warning("No category names for \(Category.self) id \(id)")
            return nil
        }
        let category = context.findOrCreate(Category.self, key: id)

        for (language, name) in categoryNames.value {
            let localization = context.findOrCreate(LocalizedCategory.self,
                                                    key: (category: category, language: language))
            localization.name = name
        }

        return category
    }

    // MARK: Orphans

    func deleteOrphans(fetchedCategoryIds: [String], context: NSManagedObjectContext) throws {
        // List existing objects
        var orphanedObjects: Set<Category>
        switch scope {
        case .all:
            orphanedObjects = Set(context.objects(Category.self).fetch())
        case .single:
            orphanedObjects = Set()
        }

        orphanedObjects = orphanedObjects.filter { !fetchedCategoryIds.contains($0.id) }

        if !orphanedObjects.isEmpty {
            Logger.info("Deleting \(orphanedObjects.count) \(Category.self)(s)")
            orphanedObjects.forEach { context.delete($0) }
        }
    }

}
