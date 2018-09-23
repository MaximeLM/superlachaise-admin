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
                OpenStreetMapElement.all()(realm).compactMap { $0.wikidataEntry?.id }
            }
        case let .single(id):
            return Single.just([id])
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
            wikidataIds.compactMap { WikidataEntry.find(id: $0)(realm) }
                .flatMap { $0.secondaryWikidataEntries.map { $0.id } }
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
            try self.wikidataEntry(wikidataEntity: wikidataEntity, realm: realm).id
        }
    }

    // MARK: Wikidata entry

    func wikidataEntry(wikidataEntity: WikidataEntity, realm: Realm) throws -> WikidataEntry {
        // Wikidata Id
        let wikidataEntry = WikidataEntry.findOrCreate(id: wikidataEntity.id)(realm)

        // Localizations
        for language in config.languages {
            syncLocalization(
                wikidataEntry: wikidataEntry, wikidataEntity: wikidataEntity, language: language, realm: realm)
        }

        // Name
        wikidataEntry.name = wikidataEntry.localizations.first?.name

        // Kind
        let kind = wikidataEntryKind(wikidataEntity: wikidataEntity)
        wikidataEntry.kind = kind

        // Secondary wikidata entries
        let secondaryWikidataEntries = self.secondaryWikidataIds(wikidataEntity: wikidataEntity, kind: kind)
            .map { WikidataEntry.findOrCreate(id: $0)(realm) }
        wikidataEntry.secondaryWikidataEntries.replaceAll(objects: secondaryWikidataEntries)

        // Wikidata categories
        let wikidataCategories = self.wikidataCategoriesIds(wikidataEntity: wikidataEntity, kind: kind)
            .map { WikidataCategory.findOrCreate(id: $0)(realm) }
        wikidataEntry.wikidataCategories.replaceAll(objects: wikidataCategories)

        // Image
        let imageCommonsId = self.imageCommonsId(wikidataEntity: wikidataEntity, kind: kind)
        if imageCommonsId == nil && (kind == .grave || kind == .monument) {
            Logger.warning("\(WikidataEntry.self) \(wikidataEntry) has no image")
        }
        wikidataEntry.image = imageCommonsId.map { CommonsFile.findOrCreate(id: $0)(realm) }

        // Image of grave
        if kind == .person {
            let imageOfGraveCommonsId = self.imageOfGraveCommonsId(wikidataEntity: wikidataEntity, kind: kind)
            if imageOfGraveCommonsId == nil {
                Logger.warning("\(WikidataEntry.self) \(wikidataEntry) has no image of grave")
            }
            wikidataEntry.imageOfGrave = imageOfGraveCommonsId.map { CommonsFile.findOrCreate(id: $0)(realm) }
        }

        // Dates
        wikidataEntry.dateOfBirth = try wikidataDate(
            wikidataEntity: wikidataEntity, kind: kind, claim: .dateOfBirth)
        wikidataEntry.dateOfDeath = try wikidataDate(
            wikidataEntity: wikidataEntity, kind: kind, claim: .dateOfDeath)

        return wikidataEntry
    }

    @discardableResult
    func syncLocalization(wikidataEntry: WikidataEntry,
                          wikidataEntity: WikidataEntity,
                          language: String,
                          realm: Realm) -> WikidataLocalizedEntry {
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

        return localization
    }

    func wikidataEntryKind(wikidataEntity: WikidataEntity) -> EntryKind? {
        let instanceOfs = wikidataEntity.claims(.instanceOf)
            .compactMap { $0.mainsnak.entityName }
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

    func secondaryWikidataIds(wikidataEntity: WikidataEntity, kind: EntryKind?) -> [String] {
        var secondaryWikidataNames: [WikidataEntityName] = []

        if kind == .grave {
            // Persons buried in the grave
            let entityNames = wikidataEntity.claims(.instanceOf)
                .filter { claim in
                    guard let entityName = claim.mainsnak.entityName else {
                        return false
                    }
                    return [.grave, .tomb, .cardiotaph].contains(entityName)
                }
                .flatMap { $0.qualifiers(.of) }
                .compactMap { $0.entityName }
            secondaryWikidataNames.append(contentsOf: entityNames)
        }

        if kind == .monument {
            // Subject of the monument
            let claims = [
                wikidataEntity.claims(.commemorates),
                wikidataEntity.claims(.mainSubject),
            ]
            let entityNames = claims
                .flatMap { $0 }
                .compactMap { $0.mainsnak.entityName }
            secondaryWikidataNames.append(contentsOf: entityNames)
        }

        // Custom secondary entries
        if let customSecondaryWikidataIds = config.customSecondaryWikidataIds[wikidataEntity.id] {
            let customSecondaryWikidataNames = customSecondaryWikidataIds.map { WikidataEntityName(rawValue: $0) }
            secondaryWikidataNames.append(contentsOf: customSecondaryWikidataNames)
        }

        return secondaryWikidataNames.map { $0.rawValue }.uniqueValues()
    }

    func wikidataCategoriesIds(wikidataEntity: WikidataEntity, kind: EntryKind?) -> [String] {
        var wikidataCategoriesNames: [WikidataEntityName] = []

        if kind == .person {
            let claims = [
                wikidataEntity.claims(.occupation),
                wikidataEntity.claims(.sexOrGender),
            ]
            let entityNames = claims
                .flatMap { $0 }
                .compactMap { $0.mainsnak.entityName }
            wikidataCategoriesNames.append(contentsOf: entityNames)
        }

        return wikidataCategoriesNames.map { $0.rawValue }.uniqueValues()
    }

    func wikidataDate(wikidataEntity: WikidataEntity,
                      kind: EntryKind?,
                      claim: WikidataPropertyName) throws -> EntryDate? {
        guard kind == .person else {
            return nil
        }
        return try wikidataEntity.claims(claim)
            .compactMap { wikidataClaim -> WikidataClaimTimeValue? in
                guard let timeValue = wikidataClaim.mainsnak.timeValue else {
                    Logger.warning(
                        "\(WikidataEntity.self) \(wikidataEntity) has an invalid timeValue for \(claim.rawValue)")
                    return nil
                }
                return timeValue
            }
            .max { $0.precision < $1.precision }
            .map { try $0.entryDate() }
    }

    func imageCommonsId(wikidataEntity: WikidataEntity, kind: EntryKind?) -> String? {
        return wikidataEntity.claims(.image)
            .compactMap { $0.mainsnak.stringValue }
            .first
    }

    func imageOfGraveCommonsId(wikidataEntity: WikidataEntity, kind: EntryKind?) -> String? {
        return wikidataEntity.claims(.imageOfGrave)
            .compactMap { $0.mainsnak.stringValue }
            .first
    }

    // MARK: Orphans

    func deleteOrphans(fetchedIds: [String]) -> Single<Void> {
        return Realm.async(dispatchQueue: realmDispatchQueue) { realm in
            try realm.write {
                try self.deleteOrphans(fetchedIds: fetchedIds, realm: realm)
            }
        }
    }

    func deleteOrphans(fetchedIds: [String], realm: Realm) throws {
        // List existing objects
        var orphanedObjects: Set<WikidataEntry>
        switch scope {
        case .all:
            orphanedObjects = Set(WikidataEntry.all()(realm))
        case .single:
            orphanedObjects = Set()
        }

        orphanedObjects = orphanedObjects.filter { !fetchedIds.contains($0.id) }

        if !orphanedObjects.isEmpty {
            Logger.info("Deleting \(orphanedObjects.count) \(WikidataEntry.self)(s)")
            orphanedObjects.forEach { $0.delete() }
        }
    }

}
