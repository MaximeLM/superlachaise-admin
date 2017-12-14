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

    enum Scope {
        case all
        case list(wikidataIds: [String])
    }

    let scope: Scope

    let config: WikidataConfig
    let endpoint: APIEndpointType

    init(scope: Scope, config: WikidataConfig, endpoint: APIEndpointType) {
        self.scope = scope
        self.config = config
        self.endpoint = endpoint
    }

    private let realmDispatchQueue = DispatchQueue(label: "SyncWikidataEntries.realm")

    // MARK: Execution

    func asCompletable() -> Completable {
        return primaryWikidataEntries()
            .flatMap(self.withSecondaryWikidataEntries)
            .flatMap(self.deleteOrphans)
            .toCompletable()
    }

}

private extension SyncWikidataEntries {

    // MARK: Primary Wikidata entries

    func primaryWikidataEntries() -> Single<[String]> {
        return primaryWikidataIds()
            .flatMap(self.wikidataEntities)
            .flatMap(self.saveWikidataEntries)
            .do(onNext: { Logger.info("Fetched \($0.count) primary \(WikidataEntry.self)(s)") })
    }

    func primaryWikidataIds() -> Single<[String]> {
        switch self.scope {
        case .all:
            // Get wikidata ids from OpenStreetMap elements
            return Realm.async(dispatchQueue: realmDispatchQueue) { realm in
                return OpenStreetMapElement.all()(realm).flatMap { $0.wikidataId }
            }
        case let .list(wikidataIds):
            return Single.just(wikidataIds)
        }
    }

    // MARK: Secondary Wikidata entries

    /**
     Recursively get secondary entries
    */
    func withSecondaryWikidataEntries(wikidataIds: [String]) -> Single<[String]> {
        return secondaryWikidataIds(wikidataIds: wikidataIds)
            .flatMap { secondaryWikidataIds in
                if secondaryWikidataIds.isEmpty {
                    return Single.just(wikidataIds)
                } else {
                    return self.wikidataEntities(wikidataIds: secondaryWikidataIds)
                        .flatMap(self.saveWikidataEntries)
                        .do(onNext: { Logger.info("Fetched \($0.count) secondary \(WikidataEntry.self)(s)") })
                        .map { wikidataIds + $0 }
                }
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

            // Wikipedia title
            let wikipediaTitle = wikidataEntity.sitelinks["\(language)wiki"]?.title
            localization.wikipediaTitle = wikipediaTitle
        }

        // Name
        wikidataEntry.name = wikidataEntry.localizations.first?.name

        // Kind
        let kind = wikidataEntryKind(wikidataEntity: wikidataEntity)
        wikidataEntry.kind = kind

        // Secondary wikidata ids
        let secondaryWikidataIds = self.secondaryWikidataIds(wikidataEntity: wikidataEntity, kind: kind)
        wikidataEntry.secondaryWikidataIds.replaceAll(objects: secondaryWikidataIds)

        // Wikidata category ids
        let wikidataCategoryIds = self.wikidataCategoryIds(wikidataEntity: wikidataEntity, kind: kind)
        wikidataEntry.wikidataCategoryIds.replaceAll(objects: wikidataCategoryIds)

        // Dates
        wikidataEntry.dateOfBirth = try wikidataDate(wikidataEntity: wikidataEntity, kind: kind, claim: .dateOfBirth)
        wikidataEntry.dateOfDeath = try wikidataDate(wikidataEntity: wikidataEntity, kind: kind, claim: .dateOfDeath)

        return wikidataEntry
    }

    func wikidataEntryKind(wikidataEntity: WikidataEntity) -> WikidataEntryKind? {
        let instanceOfs = wikidataEntity.claims(.instanceOf)?
            .flatMap { $0.mainsnak.entityName }
        for instanceOf in instanceOfs ?? [] {
            if [.human].contains(instanceOf) {
                let claims: [WikidataPropertyName] = [.placeOfBurial]
                let validLocations = claims
                    .flatMap { wikidataEntity.claims($0) }
                    .flatMap { $0.flatMap { $0.mainsnak.entityName } }
                    .filter { isValidLocation($0) }
                if !validLocations.isEmpty {
                    return .graveOf
                }
            }
            if [.grave, .tomb, .cardiotaph].contains(instanceOf) {
                let claims: [WikidataPropertyName] = [.location, .partOf, .placeOfBurial]
                let validLocations = claims
                    .flatMap { wikidataEntity.claims($0) }
                    .flatMap { $0.flatMap { $0.mainsnak.entityName } }
                    .filter { isValidLocation($0) }
                if !validLocations.isEmpty {
                    return .grave
                }
            }
            if [.monument, .memorial, .warMemorial].contains(instanceOf) {
                let claims: [WikidataPropertyName] = [.location, .partOf, .placeOfBurial]
                let validLocations = claims
                    .flatMap { wikidataEntity.claims($0) }
                    .flatMap { $0.flatMap { $0.mainsnak.entityName } }
                    .filter { isValidLocation($0) }
                if !validLocations.isEmpty {
                    return .grave
                }
            }
        }
        return nil
    }

    func isValidLocation(_ location: WikidataEntityName) -> Bool {
        return config.validLocations.contains(location)
    }

    func secondaryWikidataIds(wikidataEntity: WikidataEntity, kind: WikidataEntryKind?) -> [String] {
        var secondaryWikidataNames: [WikidataEntityName] = []

        if kind == .grave {
            let entityNames = (wikidataEntity.claims(.instanceOf) ?? [])
                .filter { claim in
                    guard let entityName = claim.mainsnak.entityName else {
                        return false
                    }
                    return [.grave, .tomb, .cardiotaph].contains(entityName)
                }
                .flatMap { $0.qualifiers(.of) ?? [] }
                .flatMap { $0.entityName }
            secondaryWikidataNames.append(contentsOf: entityNames)
        }

        if kind == .monument {
            let claims = [
                wikidataEntity.claims(.commemorates),
                wikidataEntity.claims(.mainSubject),
            ]
            let entityNames = claims
                .flatMap { $0 ?? [] }
                .flatMap { $0.mainsnak.entityName }
            secondaryWikidataNames.append(contentsOf: entityNames)
        }

        let wikidataEntityName = WikidataEntityName(rawValue: wikidataEntity.id)
        if let customSecondaryWikidataIds = config.customSecondaryWikidataIds[wikidataEntityName] {
            secondaryWikidataNames.append(contentsOf: customSecondaryWikidataIds)
        }

        return secondaryWikidataNames.map { $0.rawValue }.uniqueValues()
    }

    func wikidataCategoryIds(wikidataEntity: WikidataEntity, kind: WikidataEntryKind?) -> [String] {
        var wikidataCategoryNames: [WikidataEntityName] = []

        if kind == .graveOf {
            let claims = [
                wikidataEntity.claims(.occupation),
                wikidataEntity.claims(.sexOrGender),
            ]
            let entityNames = claims
                .flatMap { $0 ?? [] }
                .flatMap { $0.mainsnak.entityName }
            wikidataCategoryNames.append(contentsOf: entityNames)
        }

        return wikidataCategoryNames.map { $0.rawValue }.uniqueValues()
    }

    func wikidataDate(wikidataEntity: WikidataEntity,
                      kind: WikidataEntryKind?,
                      claim: WikidataPropertyName) throws -> WikidataDate? {
        guard kind == .graveOf else {
            return nil
        }
        return try wikidataEntity.claims(claim)?
            .flatMap { $0.mainsnak.timeValue }
            .max { $0.precision < $1.precision }
            .map { try $0.wikidataDate() }
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
        case .list:
            orphanedObjects = Set()
        }

        orphanedObjects = orphanedObjects.filter { !fetchedWikidataIds.contains($0.wikidataId) }

        if !orphanedObjects.isEmpty {
            orphanedObjects.forEach { $0.deleted = true }
            Logger.info("Flagged \(orphanedObjects.count) \(WikidataEntry.self)(s) for deletion")
        }
    }

}
