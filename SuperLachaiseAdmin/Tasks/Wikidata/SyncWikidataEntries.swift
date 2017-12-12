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
    let languages: [String]

    let endpoint: APIEndpointType

    init(scope: Scope, languages: [String], endpoint: APIEndpointType) {
        self.scope = scope
        self.languages = languages
        self.endpoint = endpoint
    }

    private let realmDispatchQueue = DispatchQueue(label: "SyncWikidataEntries.realm")

    // MARK: Execution

    func asCompletable() -> Completable {
        return primaryWikidataEntities()
            .flatMap(self.primaryWikidataEntries)
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
                return SuperLachaisePOI.list()(realm).map { $0.wikidataId }
            }
        case let .list(wikidataIds):
            return Single.just(wikidataIds)
        }
    }

    private func primaryWikidataEntities(wikidataIds: [String]) -> Single<[WikidataEntity]> {
        return WikidataGetEntities(endpoint: endpoint, wikidataIds: wikidataIds, languages: languages)
            .asSingle()
    }

    // MARK: Primary Wikidata entries

    private func primaryWikidataEntries(wikidataEntities: [WikidataEntity]) -> Single<[WikidataEntry]> {
        return Realm.async(dispatchQueue: realmDispatchQueue) { realm in
            return try realm.write {
                try self.primaryWikidataEntries(wikidataEntities: wikidataEntities, realm: realm)
            }
        }
    }

    private func primaryWikidataEntries(wikidataEntities: [WikidataEntity], realm: Realm) throws -> [WikidataEntry] {
        let fetchedObjects = try wikidataEntities.map { wikidataEntity -> WikidataEntry in
            try self.primaryWikidataEntry(wikidataEntity: wikidataEntity, realm: realm)
        }
        Logger.info("Fetched \(fetchedObjects.count) primary \(WikidataEntry.self)(s)")
        return fetchedObjects
    }

    private func primaryWikidataEntry(wikidataEntity: WikidataEntity, realm: Realm) throws -> WikidataEntry {
        // Wikidata Id
        let wikidataEntry = realm.findOrCreateObject(ofType: WikidataEntry.self, forPrimaryKey: wikidataEntity.id)
        wikidataEntry.toBeDeleted = false

        return wikidataEntry
    }

}
