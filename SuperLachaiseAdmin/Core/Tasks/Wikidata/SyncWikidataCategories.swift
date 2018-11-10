//
//  SyncWikidataCategories.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 03/03/2018.
//

import CoreData
import Foundation
import RxSwift

final class SyncWikidataCategories: Task {

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

    let config: WikidataConfig
    let endpoint: APIEndpointType
    let performInBackground: Single<NSManagedObjectContext>

    init(scope: Scope,
         config: WikidataConfig,
         endpoint: APIEndpointType,
         performInBackground: Single<NSManagedObjectContext>) {
        self.scope = scope
        self.config = config
        self.endpoint = endpoint
        self.performInBackground = performInBackground
    }

    var description: String {
        return "\(type(of: self)) (\(scope.description))"
    }

    // MARK: Execution

    func asSingle() -> Single<Void> {
        return wikidataCategories()
            .flatMap(self.deleteOrphans)
    }

}

private extension SyncWikidataCategories {

    // MARK: Wikidata categories

    func wikidataCategories() -> Single<[String]> {
        return wikidataIds()
            .flatMap(self.wikidataEntities)
            .flatMap(self.saveWikidataCategories)
            .do(onSuccess: { Logger.info("Fetched \($0.count) \(WikidataCategory.self)(s)") })
    }

    func wikidataIds() -> Single<[String]> {
        switch self.scope {
        case .all:
            // Get wikidata ids from Wikidata entries
            return performInBackground.map { context in
                context.objects(WikidataEntry.self).fetch().flatMap { $0.wikidataCategories.map { $0.id } }
            }
        case let .single(wikidataId):
            return Single.just([wikidataId])
        }
    }

    // MARK: Wikidata entities

    func wikidataEntities(wikidataIds: [String]) -> Single<[WikidataEntity]> {
        return WikidataGetEntities(endpoint: endpoint, wikidataIds: wikidataIds, languages: config.languages)
            .asSingle()
    }

    // MARK: Wikidata categories

    func saveWikidataCategories(wikidataEntities: [WikidataEntity]) -> Single<[String]> {
        return performInBackground.map { context in
            try context.write {
                try self.saveWikidataCategories(wikidataEntities: wikidataEntities, context: context)
            }
        }
    }

    func saveWikidataCategories(wikidataEntities: [WikidataEntity],
                                context: NSManagedObjectContext) throws -> [String] {
        return try wikidataEntities.map { wikidataEntity in
            try self.wikidataCategory(wikidataEntity: wikidataEntity, context: context).id
        }
    }

    // MARK: Wikidata category

    func wikidataCategory(wikidataEntity: WikidataEntity,
                          context: NSManagedObjectContext) throws -> WikidataCategory {
        // Wikidata Id
        let wikidataId = wikidataEntity.id
        let wikidataCategory = context.findOrCreate(WikidataCategory.self, key: wikidataId)

        // Localizations
        let names = config.languages.compactMap { language -> String? in
            let name = wikidataEntity.labels[language]?.value
            if name == nil {
                Logger.warning("\(WikidataCategory.self) \(wikidataCategory) has no name in \(language)")
            }
            return name
        }

        // Name
        wikidataCategory.name = names.first

        // Categories
        if let categories = config.categories[wikidataId]?
            .map({ context.findOrCreate(Category.self, key: $0) }) {
            wikidataCategory.categories = Set(categories)
        } else {
            Logger.warning("\(WikidataCategory.self) \(wikidataCategory) has no categories")
            wikidataCategory.categories = Set()
        }

        return wikidataCategory
    }

    // MARK: Orphans

    func deleteOrphans(fetchedIds: [String]) -> Single<Void> {
        return performInBackground.map { context in
            try context.write {
                try self.deleteOrphans(fetchedIds: fetchedIds, context: context)
            }
        }
    }

    func deleteOrphans(fetchedIds: [String], context: NSManagedObjectContext) throws {
        // List existing objects
        var orphanedObjects: Set<WikidataCategory>
        switch scope {
        case .all:
            orphanedObjects = Set(context.objects(WikidataCategory.self).fetch())
        case .single:
            orphanedObjects = Set()
        }

        orphanedObjects = orphanedObjects.filter { !fetchedIds.contains($0.id) }

        if !orphanedObjects.isEmpty {
            Logger.info("Deleting \(orphanedObjects.count) \(WikidataCategory.self)(s)")
            orphanedObjects.forEach { context.delete($0) }
        }
    }

}
