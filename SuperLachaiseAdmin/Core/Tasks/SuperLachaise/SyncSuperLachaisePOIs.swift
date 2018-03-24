//
//  SyncSuperLachaisePOIs.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 24/03/2018.
//

import Foundation

import Foundation
import RealmSwift
import RxSwift

final class SyncSuperLachaisePOIs: Task {

    enum Scope: CustomStringConvertible {

        case all
        case single(superLachaiseId: SuperLachaiseId)

        var description: String {
            switch self {
            case .all:
                return "all"
            case let .single(superLachaiseId):
                return superLachaiseId.description
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
                let superLachaisePOIs = self.superLachaisePOIs(realm: realm)
                self.deleteOrphans(syncedObjects: superLachaisePOIs, realm: realm)
            }
        }
    }

    // MARK: Private properties

    private let realmDispatchQueue = DispatchQueue(label: "SyncSuperLachaisePOIs.realm")

}

private extension SyncSuperLachaisePOIs {

    func superLachaisePOIs(realm: Realm) -> [SuperLachaisePOI] {
        let superLachaisePOIs = openStreetMapElements(realm: realm)
            .flatMap { openStreetMapElement -> [SuperLachaisePOI] in
                guard let wikidataEntry = openStreetMapElement.wikidataEntry else {
                    Logger.warning(
                        "\(OpenStreetMapElement.self) \(openStreetMapElement) has no wikidata entry; skipping")
                    return []
                }
                return config.languages.flatMap { language in
                    superLachaisePOI(openStreetMapElement: openStreetMapElement,
                                     wikidataEntry: wikidataEntry,
                                     language: language,
                                     realm: realm)
                }
            }

        let crossReference = Dictionary(grouping: superLachaisePOIs, by: { $0 })
        let duplicates = crossReference.filter { $0.value.count > 1 }
        for duplicate in duplicates {
            Logger.warning("""
                \(SuperLachaisePOI.self) \(duplicate.key) is referenced by multiple OpenStreetMap elements; \
                skipping
                """)
        }

        return superLachaisePOIs
            .filter { !duplicates.keys.contains($0) }
    }

    func openStreetMapElements(realm: Realm) -> [OpenStreetMapElement] {
        switch self.scope {
        case .all:
            return Array(OpenStreetMapElement.all()(realm))
        case let .single(superLachaiseId):
            return Array(realm.objects(OpenStreetMapElement.self)
                .filter("deleted == false && wikidataEntry.wikidataId == %@", superLachaiseId.wikidataId))
        }
    }

    func superLachaisePOIs(result: [SuperLachaisePOI],
                           openStreetMapElement: OpenStreetMapElement,
                           realm: Realm) -> [SuperLachaisePOI] {
        var result = result
        guard let wikidataEntry = openStreetMapElement.wikidataEntry else {
            Logger.warning("\(OpenStreetMapElement.self) \(openStreetMapElement) has no wikidata entry; skipping")
            return result
        }

        for language in config.languages {
            if let superLachaisePOI = self.superLachaisePOI(
                openStreetMapElement: openStreetMapElement,
                wikidataEntry: wikidataEntry,
                language: language,
                realm: realm) {
                if let index = result.index(where: { $0.superLachaiseId == superLachaisePOI.superLachaiseId }) {
                    Logger.warning("""
                    \(SuperLachaisePOI.self) \(superLachaisePOI) is referenced by multiple OpenStreetMap elements; \
                    skipping
                    """)
                    result.remove(at: index)
                } else {
                    result.append(superLachaisePOI)
                }
            }
        }

        return result
    }

    func superLachaisePOI(openStreetMapElement: OpenStreetMapElement,
                          wikidataEntry: WikidataEntry,
                          language: String,
                          realm: Realm) -> SuperLachaisePOI? {
        let superLachaiseId = SuperLachaiseId(language: language, wikidataId: wikidataEntry.wikidataId)
        let superLachaisePOI = SuperLachaisePOI.findOrCreate(superLachaiseId: superLachaiseId)(realm)
        superLachaisePOI.deleted = false

        superLachaisePOI.name = openStreetMapElement.name
        superLachaisePOI.latitude = openStreetMapElement.latitude
        superLachaisePOI.longitude = openStreetMapElement.longitude

        return superLachaisePOI
    }

    // MARK: Orphans

    func deleteOrphans(syncedObjects: [SuperLachaisePOI], realm: Realm) {
        // List existing objects
        var orphanedObjects: Set<SuperLachaisePOI>
        switch scope {
        case .all:
            orphanedObjects = Set(SuperLachaisePOI.all()(realm))
        case .single:
            orphanedObjects = Set()
        }

        orphanedObjects = orphanedObjects.filter { !syncedObjects.contains($0) }

        if !orphanedObjects.isEmpty {
            orphanedObjects.forEach { $0.deleted = true }
            Logger.info("Flagged \(orphanedObjects.count) \(SuperLachaisePOI.self)(s) for deletion")
        }
    }

}
