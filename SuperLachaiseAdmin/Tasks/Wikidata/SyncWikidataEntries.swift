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
        return primaryWikidataEntities()
            .flatMap(self.wikidataEntries)
            .do(onNext: { Logger.info("Fetched \($0.count) primary \(WikidataEntry.self)(s)") })
            .asObservable().ignoreElements()
    }

    // MARK: Primary Wikidata entities

    private func primaryWikidataEntities() -> Single<[WikidataEntity]> {
        return primaryWikidataIds()
            .flatMap(self.primaryWikidataEntities)
    }

    private func primaryWikidataIds() -> Single<[String]> {
        switch self.scope {
        case .all:
            return Realm.async(dispatchQueue: realmDispatchQueue) { realm in
                return SuperLachaisePOI.all()(realm).map { $0.wikidataId }
            }
        case let .list(wikidataIds):
            return Single.just(wikidataIds)
        }
    }

    private func primaryWikidataEntities(wikidataIds: [String]) -> Single<[WikidataEntity]> {
        return WikidataGetEntities(endpoint: endpoint, wikidataIds: wikidataIds, languages: config.languages)
            .asSingle()
    }

    // MARK: Wikidata entries

    private func wikidataEntries(wikidataEntities: [WikidataEntity]) -> Single<[WikidataEntry]> {
        return Realm.async(dispatchQueue: realmDispatchQueue) { realm in
            return try realm.write {
                try self.wikidataEntries(wikidataEntities: wikidataEntities, realm: realm)
            }
        }
    }

    private func wikidataEntries(wikidataEntities: [WikidataEntity], realm: Realm) throws -> [WikidataEntry] {
        return try wikidataEntities.map { wikidataEntity -> WikidataEntry in
            try self.wikidataEntry(wikidataEntity: wikidataEntity, realm: realm)
        }
    }

    private func wikidataEntry(wikidataEntity: WikidataEntity, realm: Realm) throws -> WikidataEntry {
        // Wikidata Id
        let wikidataEntry = WikidataEntry.findOrCreate(wikidataId: wikidataEntity.id)(realm)
        wikidataEntry.deleted = false

        // Kind
        wikidataEntry.kind = wikidataEntryKind(wikidataEntity: wikidataEntity)

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

        return wikidataEntry
    }

    private func wikidataEntryKind(wikidataEntity: WikidataEntity) -> WikidataEntryKind? {
        let instanceOfs = wikidataEntity.claims(.instanceOf)?
            .flatMap { $0.mainsnak.entityValue }
        for instanceOf in instanceOfs ?? [] {
            if [.human].contains(instanceOf) {
                let locations = [
                    wikidataEntity.claims(.placeOfBurial),
                ]
                    .flatMap { $0?.flatMap { $0.mainsnak.entityValue } ?? [] }
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
                    .flatMap { $0?.flatMap { $0.mainsnak.entityValue } ?? [] }
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
                    .flatMap { $0?.flatMap { $0.mainsnak.entityValue } ?? [] }
                if containsValidLocation(locations) {
                    return .monument
                }
            }
        }
        return nil
    }

    private func containsValidLocation(_ locations: [WikidataEntityName]) -> Bool {
        return !Set(locations).isDisjoint(with: config.validLocations)
    }

}
