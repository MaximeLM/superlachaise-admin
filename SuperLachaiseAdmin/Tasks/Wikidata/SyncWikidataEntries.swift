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
            .asObservable().ignoreElements()
    }

}

private extension SyncWikidataEntries {

    // MARK: Primary Wikidata entries

    func primaryWikidataEntries() -> Single<[WikidataEntry]> {
        return primaryWikidataIds()
            .flatMap(self.wikidataEntities)
            .flatMap(self.wikidataEntries)
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
    func withSecondaryWikidataEntries(wikidataEntries: [WikidataEntry]) -> Single<[WikidataEntry]> {
        let secondaryWikidataIds = self.secondaryWikidataIds(wikidataEntries: wikidataEntries)
        if secondaryWikidataIds.isEmpty {
            return Single.just(wikidataEntries)
        } else {
            return wikidataEntities(wikidataIds: secondaryWikidataIds)
                .flatMap(self.wikidataEntries)
                .do(onNext: { Logger.info("Fetched \($0.count) secondary \(WikidataEntry.self)(s)") })
                .map { wikidataEntries + $0 }
        }
    }

    func secondaryWikidataIds(wikidataEntries: [WikidataEntry]) -> [String] {
        let wikidataIds = wikidataEntries.map { $0.wikidataId }
        return wikidataEntries
            .flatMap { Array($0.secondaryWikidataIds) }
            .filter { !wikidataIds.contains($0) }
    }

    // MARK: Wikidata entities

    func wikidataEntities(wikidataIds: [String]) -> Single<[WikidataEntity]> {
        return WikidataGetEntities(endpoint: endpoint, wikidataIds: wikidataIds, languages: config.languages)
            .asSingle()
    }

    // MARK: Wikidata entries

    func wikidataEntries(wikidataEntities: [WikidataEntity]) -> Single<[WikidataEntry]> {
        return Realm.async(dispatchQueue: realmDispatchQueue) { realm in
            return try realm.write {
                try self.wikidataEntries(wikidataEntities: wikidataEntities, realm: realm)
            }
        }
    }

    func wikidataEntries(wikidataEntities: [WikidataEntity], realm: Realm) throws -> [WikidataEntry] {
        return try wikidataEntities.map { wikidataEntity -> WikidataEntry in
            try self.wikidataEntry(wikidataEntity: wikidataEntity, realm: realm)
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

        // Kind
        let kind = wikidataEntryKind(wikidataEntity: wikidataEntity)
        wikidataEntry.kind = kind

        // Secondary wikidata ids
        wikidataEntry.secondaryWikidataIds.set(secondaryWikidataIds(wikidataEntity: wikidataEntity, kind: kind))

        // Wikidata category ids
        wikidataEntry.wikidataCategoryIds.set(wikidataCategoryIds(wikidataEntity: wikidataEntity, kind: kind))

        // Name
        wikidataEntry.name = wikidataEntry.localizations.first?.name

        return wikidataEntry
    }

    func wikidataEntryKind(wikidataEntity: WikidataEntity) -> WikidataEntryKind? {
        let instanceOfs = wikidataEntity.claims(.instanceOf)?
            .flatMap { $0.mainsnak.entityName }
        for instanceOf in instanceOfs ?? [] {
            if [.human].contains(instanceOf) {
                let locations = [
                    wikidataEntity.claims(.placeOfBurial),
                ]
                    .flatMap { $0?.flatMap { $0.mainsnak.entityName } ?? [] }
                if containsValidLocation(locations) {
                    return .graveOf
                }
            }
            if [.grave, .tomb, .cardiotaph].contains(instanceOf) {
                let locations = [
                    wikidataEntity.claims(.location),
                    wikidataEntity.claims(.partOf),
                    wikidataEntity.claims(.placeOfBurial),
                ]
                    .flatMap { $0?.flatMap { $0.mainsnak.entityName } ?? [] }
                if containsValidLocation(locations) {
                    return .grave
                }
            }
            if [.monument, .memorial, .warMemorial].contains(instanceOf) {
                let locations = [
                    wikidataEntity.claims(.location),
                    wikidataEntity.claims(.partOf),
                    wikidataEntity.claims(.placeOfBurial),
                ]
                    .flatMap { $0?.flatMap { $0.mainsnak.entityName } ?? [] }
                if containsValidLocation(locations) {
                    return .monument
                }
            }
        }
        return nil
    }

    func containsValidLocation(_ locations: [WikidataEntityName]) -> Bool {
        return !Set(locations).isDisjoint(with: config.validLocations)
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

        return secondaryWikidataNames.map { $0.rawValue }
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

        return wikidataCategoryNames.map { $0.rawValue }
    }

}
