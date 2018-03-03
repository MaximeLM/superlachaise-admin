//
//  SyncWikidataCategories.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 03/03/2018.
//

import Foundation
import RealmSwift
import RxSwift

final class SyncWikidataCategories: Task {

    enum Scope: CustomStringConvertible {

        case all
        case single(wikidataId: String)

        var description: String {
            switch self {
            case .all:
                return "all"
            case let .single(wikidataId):
                return wikidataId
            }
        }

    }

    let scope: Scope

    let config: WikidataConfig
    let endpoint: APIEndpointType

    init(scope: Scope, config: WikidataConfig, endpoint: APIEndpointType) {
        self.scope = scope
        self.config = config
        self.endpoint = endpoint
    }

    var description: String {
        return "\(type(of: self)) (\(scope.description))"
    }

    // MARK: Execution

    func asSingle() -> Single<Void> {
        return wikidataCategories()
            .flatMap(self.deleteOrphans)
    }

    // MARK: Private properties

    private let realmDispatchQueue = DispatchQueue(label: "SyncWikidataCategories.realm")

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
            return Realm.async(dispatchQueue: realmDispatchQueue) { realm in
                return WikidataEntry.all()(realm).flatMap { $0.wikidataCategoriesIds }
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
        return Realm.async(dispatchQueue: realmDispatchQueue) { realm in
            try realm.write {
                try self.saveWikidataCategories(wikidataEntities: wikidataEntities, realm: realm)
            }
        }
    }

    func saveWikidataCategories(wikidataEntities: [WikidataEntity], realm: Realm) throws -> [String] {
        return try wikidataEntities.map { wikidataEntity in
            try self.wikidataCategory(wikidataEntity: wikidataEntity, realm: realm).wikidataId
        }
    }

    // MARK: Wikidata category

    func wikidataCategory(wikidataEntity: WikidataEntity, realm: Realm) throws -> WikidataCategory {
        // Wikidata Id
        let wikidataCategory = WikidataCategory.findOrCreate(wikidataId: wikidataEntity.id)(realm)
        wikidataCategory.deleted = false

        // Localizations
        let names = config.languages.flatMap { language in
            let name = wikidataEntity.labels[language]?.value
            if name == nil {
                Logger.warning("\(WikidataCategory.self) \(wikidataCategory) has no name in \(language)")
            }
            return name
        }

        // Name
        wikidataCategory.name = names.first

        return wikidataCategory
    }

    // MARK: Orphans

    func deleteOrphans(fetchedWikidataIds: [String]) -> Single<Void> {
        return Realm.async(dispatchQueue: realmDispatchQueue) { realm in
            try realm.write {
                try self.deleteOrphans(fetchedWikidataIds: fetchedWikidataIds, realm: realm)
            }
        }
    }

    func deleteOrphans(fetchedWikidataIds: [String], realm: Realm) throws {
        // List existing objects
        var orphanedObjects: Set<WikidataCategory>
        switch scope {
        case .all:
            orphanedObjects = Set(WikidataCategory.all()(realm))
        case .single:
            orphanedObjects = Set()
        }

        orphanedObjects = orphanedObjects.filter { !fetchedWikidataIds.contains($0.wikidataId) }

        if !orphanedObjects.isEmpty {
            orphanedObjects.forEach { $0.deleted = true }
            Logger.info("Flagged \(orphanedObjects.count) \(WikidataCategory.self)(s) for deletion")
        }
    }

}
