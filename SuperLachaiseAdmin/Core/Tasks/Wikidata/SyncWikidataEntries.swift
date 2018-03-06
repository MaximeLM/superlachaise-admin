//
//  SyncWikidataEntries.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 10/12/2017.
//

import Foundation
import RealmSwift
import RxSwift

final class SyncWikidataEntries: Task {

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
        return primaryWikidataEntries()
            .flatMap(self.withSecondaryWikidataEntries)
            .flatMap(self.deleteOrphans)
    }

    // MARK: Private properties

    private let realmDispatchQueue = DispatchQueue(label: "SyncWikidataEntries.realm")

}

private extension SyncWikidataEntries {

    // MARK: Primary Wikidata entries

    func primaryWikidataEntries() -> Single<[String]> {
        return primaryWikidataIds()
            .flatMap(self.wikidataEntities)
            .flatMap(self.saveWikidataEntries)
            .do(onSuccess: { Logger.info("Fetched \($0.count) primary \(WikidataEntry.self)(s)") })
    }

    func primaryWikidataIds() -> Single<[String]> {
        switch self.scope {
        case .all:
            // Get wikidata ids from OpenStreetMap elements
            return Realm.async(dispatchQueue: realmDispatchQueue) { realm in
                return OpenStreetMapElement.all()(realm).flatMap { $0.wikidataEntry?.wikidataId }
            }
        case let .single(wikidataId):
            return Single.just([wikidataId])
        }
    }

    // MARK: Secondary Wikidata entries

    /**
     Recursively get secondary entries
    */
    func withSecondaryWikidataEntries(wikidataIds: [String]) -> Single<[String]> {
        switch scope {
        case .all:
            return secondaryWikidataIds(wikidataIds: wikidataIds)
                .flatMap { secondaryWikidataIds in
                    if secondaryWikidataIds.isEmpty {
                        return Single.just(wikidataIds)
                    } else {
                        return self.wikidataEntities(wikidataIds: secondaryWikidataIds)
                            .flatMap(self.saveWikidataEntries)
                            .do(onSuccess: { Logger.info("Fetched \($0.count) secondary \(WikidataEntry.self)(s)") })
                            .map { wikidataIds + $0 }
                    }
                }
        case .single:
            return Single.just([])
        }

    }

    func secondaryWikidataIds(wikidataIds: [String]) -> Single<[String]> {
        return Realm.async(dispatchQueue: realmDispatchQueue) { realm in
            return wikidataIds.flatMap { WikidataEntry.find(wikidataId: $0)(realm) }
                .flatMap { Array($0.secondaryWikidataIds) }
                .filter { !wikidataIds.contains($0) }
        }
    }

    // MARK: Wikidata entities

    func wikidataEntities(wikidataIds: [String]) -> Single<[WikidataEntity]> {
        return WikidataGetEntities(endpoint: endpoint, wikidataIds: wikidataIds, languages: config.languages)
            .asSingle()
    }

    // MARK: Wikidata entries

    func saveWikidataEntries(wikidataEntities: [WikidataEntity]) -> Single<[String]> {
        return Realm.async(dispatchQueue: realmDispatchQueue) { realm in
            try realm.write {
                try self.saveWikidataEntries(wikidataEntities: wikidataEntities, realm: realm)
            }
        }
    }

    func saveWikidataEntries(wikidataEntities: [WikidataEntity], realm: Realm) throws -> [String] {
        return try wikidataEntities.map { wikidataEntity in
            try self.wikidataEntry(wikidataEntity: wikidataEntity, realm: realm).wikidataId
        }
    }

    // MARK: Wikidata entry

    func wikidataEntry(wikidataEntity: WikidataEntity, realm: Realm) throws -> WikidataEntry {
        // Wikidata Id
        let wikidataEntry = WikidataEntry.findOrCreate(wikidataId: wikidataEntity.id)(realm)
        wikidataEntry.deleted = false

        // Localizations
        for language in config.languages {
            let localization = wikidataEntry.findOrCreateLocalization(language: language)(realm)

            // Name
            let name = wikidataEntity.labels[language]?.value
            if name == nil {
                Logger.warning("\(WikidataEntry.self) \(wikidataEntry) has no name in \(language)")
            }
            localization.name = name

            // Summary
            let summary = wikidataEntity.descriptions[language]?.value
            if summary == nil {
                Logger.warning("\(WikidataEntry.self) \(wikidataEntry) has no summary in \(language)")
            }
            localization.summary = summary

            // Wikipedia page
            if let wikipediaTitle = wikidataEntity.sitelinks["\(language)wiki"]?.title {
                let wikipediaId = WikipediaId(language: language, title: wikipediaTitle)
                localization.wikipediaPage = WikipediaPage.findOrCreate(wikipediaId: wikipediaId)(realm)
            } else {
                localization.wikipediaPage = nil
            }

        }

        // Name
        wikidataEntry.name = wikidataEntry.localizations.first?.name

        // Nature
        let nature = wikidataEntryNature(wikidataEntity: wikidataEntity)
        wikidataEntry.nature = nature

        // Secondary wikidata ids
        let secondaryWikidataIds = self.secondaryWikidataIds(wikidataEntity: wikidataEntity, nature: nature)
        wikidataEntry.secondaryWikidataIds.replaceAll(objects: secondaryWikidataIds)

        // Wikidata categories
        let wikidataCategories = self.wikidataCategoriesIds(wikidataEntity: wikidataEntity, nature: nature)
            .map { WikidataCategory.findOrCreate(wikidataId: $0)(realm) }
        wikidataEntry.wikidataCategories.replaceAll(objects: wikidataCategories)

        // Image
        let imageCommonsId = self.imageCommonsId(wikidataEntity: wikidataEntity, nature: nature)
        if imageCommonsId == nil && (nature == .grave || nature == .monument) {
            Logger.warning("\(WikidataEntry.self) \(wikidataEntry) has no image")
        }
        wikidataEntry.image = imageCommonsId.map { CommonsFile.findOrCreate(commonsId: $0)(realm) }

        // Image of grave
        if nature == .person {
            let imageOfGraveCommonsId = self.imageOfGraveCommonsId(wikidataEntity: wikidataEntity, nature: nature)
            if imageOfGraveCommonsId == nil {
                Logger.warning("\(WikidataEntry.self) \(wikidataEntry) has no image of grave")
            }
            wikidataEntry.imageOfGrave = imageOfGraveCommonsId.map { CommonsFile.findOrCreate(commonsId: $0)(realm) }
        }

        // Dates
        wikidataEntry.dateOfBirth = try wikidataDate(wikidataEntity: wikidataEntity,
                                                     nature: nature,
                                                     claim: .dateOfBirth)
        wikidataEntry.dateOfDeath = try wikidataDate(wikidataEntity: wikidataEntity,
                                                     nature: nature,
                                                     claim: .dateOfDeath)

        return wikidataEntry
    }

    func wikidataEntryNature(wikidataEntity: WikidataEntity) -> WikidataEntryNature? {
        let instanceOfs = wikidataEntity.claims(.instanceOf)
            .flatMap { $0.mainsnak.entityName }
        for instanceOf in instanceOfs {
            if [.human].contains(instanceOf) {
                return .person
            }
            if [.grave, .tomb, .cardiotaph].contains(instanceOf) {
                return .grave
            }
            if [.monument, .memorial, .warMemorial].contains(instanceOf) {
                return .monument
            }
        }
        return nil
    }

    func secondaryWikidataIds(wikidataEntity: WikidataEntity, nature: WikidataEntryNature?) -> [String] {
        var secondaryWikidataNames: [WikidataEntityName] = []

        if nature == .grave {
            // Persons buried in the grave
            let entityNames = wikidataEntity.claims(.instanceOf)
                .filter { claim in
                    guard let entityName = claim.mainsnak.entityName else {
                        return false
                    }
                    return [.grave, .tomb, .cardiotaph].contains(entityName)
                }
                .flatMap { $0.qualifiers(.of) }
                .flatMap { $0.entityName }
            secondaryWikidataNames.append(contentsOf: entityNames)
        }

        if nature == .monument {
            // Subject of the monument
            let claims = [
                wikidataEntity.claims(.commemorates),
                wikidataEntity.claims(.mainSubject),
            ]
            let entityNames = claims
                .flatMap { $0 }
                .flatMap { $0.mainsnak.entityName }
            secondaryWikidataNames.append(contentsOf: entityNames)
        }

        // Custom secondary entries
        let wikidataEntityName = WikidataEntityName(rawValue: wikidataEntity.id)
        if let customSecondaryWikidataIds = config.customSecondaryWikidataIds[wikidataEntityName] {
            secondaryWikidataNames.append(contentsOf: customSecondaryWikidataIds)
        }

        return secondaryWikidataNames.map { $0.rawValue }.uniqueValues()
    }

    func wikidataCategoriesIds(wikidataEntity: WikidataEntity, nature: WikidataEntryNature?) -> [String] {
        var wikidataCategoriesNames: [WikidataEntityName] = []

        if nature == .person {
            let claims = [
                wikidataEntity.claims(.occupation),
                wikidataEntity.claims(.sexOrGender),
            ]
            let entityNames = claims
                .flatMap { $0 }
                .flatMap { $0.mainsnak.entityName }
            wikidataCategoriesNames.append(contentsOf: entityNames)
        }

        return wikidataCategoriesNames.map { $0.rawValue }.uniqueValues()
    }

    func wikidataDate(wikidataEntity: WikidataEntity,
                      nature: WikidataEntryNature?,
                      claim: WikidataPropertyName) throws -> WikidataDate? {
        guard nature == .person else {
            return nil
        }
        return try wikidataEntity.claims(claim)
            .flatMap { $0.mainsnak.timeValue }
            .max { $0.precision < $1.precision }
            .map { try $0.wikidataDate() }
    }

    func imageCommonsId(wikidataEntity: WikidataEntity, nature: WikidataEntryNature?) -> String? {
        return wikidataEntity.claims(.image)
            .flatMap { $0.mainsnak.stringValue }
            .first
    }

    func imageOfGraveCommonsId(wikidataEntity: WikidataEntity, nature: WikidataEntryNature?) -> String? {
        return wikidataEntity.claims(.imageOfGrave)
            .flatMap { $0.mainsnak.stringValue }
            .first
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
        var orphanedObjects: Set<WikidataEntry>
        switch scope {
        case .all:
            orphanedObjects = Set(WikidataEntry.all()(realm))
        case .single:
            orphanedObjects = Set()
        }

        orphanedObjects = orphanedObjects.filter { !fetchedWikidataIds.contains($0.wikidataId) }

        if !orphanedObjects.isEmpty {
            orphanedObjects.forEach { $0.deleted = true }
            Logger.info("Flagged \(orphanedObjects.count) \(WikidataEntry.self)(s) for deletion")
        }
    }

}
