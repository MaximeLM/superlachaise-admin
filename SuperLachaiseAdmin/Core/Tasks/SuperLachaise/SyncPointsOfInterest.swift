//
//  SyncPointsOfInterest.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 24/03/2018.
//

import Foundation
import RealmSwift
import RxSwift

final class SyncPointsOfInterest: Task {

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

    init(scope: Scope) {
        self.scope = scope
    }

    var description: String {
        return "\(type(of: self)) (\(scope.description))"
    }

    // MARK: Execution

    func asSingle() -> Single<Void> {
        return Realm.async(dispatchQueue: realmDispatchQueue) { realm in
            try realm.write {
                let pointsOfInterest = self.pointsOfInterest(realm: realm)
                self.deleteOrphans(syncedObjects: pointsOfInterest, realm: realm)
            }
        }
    }

    // MARK: Private properties

    private let realmDispatchQueue = DispatchQueue(label: "SyncPointsOfInterest.realm")

}

private extension SyncPointsOfInterest {

    func pointsOfInterest(realm: Realm) -> [PointOfInterest] {
        let pointsOfInterest = openStreetMapElements(realm: realm)
            .flatMap { openStreetMapElement -> PointOfInterest? in
                guard let wikidataEntry = openStreetMapElement.wikidataEntry else {
                    Logger.warning(
                        "\(OpenStreetMapElement.self) \(openStreetMapElement) has no wikidata entry; skipping")
                    return nil
                }
                return pointOfInterest(openStreetMapElement: openStreetMapElement,
                                       wikidataEntry: wikidataEntry,
                                       realm: realm)
            }

        let crossReference = Dictionary(grouping: pointsOfInterest, by: { $0 })
        let duplicates = crossReference.filter { $0.value.count > 1 }
        for duplicate in duplicates {
            Logger.warning("""
                \(PointOfInterest.self) \(duplicate.key) is referenced by multiple OpenStreetMap elements; \
                skipping
                """)
        }

        return pointsOfInterest
            .filter { !duplicates.keys.contains($0) }
    }

    func openStreetMapElements(realm: Realm) -> [OpenStreetMapElement] {
        switch self.scope {
        case .all:
            return Array(OpenStreetMapElement.all()(realm))
        case let .single(id):
            return Array(realm.objects(OpenStreetMapElement.self)
                .filter("deleted == false && wikidataEntry.wikidataId == %@", id))
        }
    }

    func pointOfInterest(openStreetMapElement: OpenStreetMapElement,
                         wikidataEntry: WikidataEntry,
                         realm: Realm) -> PointOfInterest? {
        let pointOfInterest = PointOfInterest.findOrCreate(id: wikidataEntry.wikidataId)(realm)
        pointOfInterest.deleted = false

        pointOfInterest.name = openStreetMapElement.name
        pointOfInterest.latitude = openStreetMapElement.latitude
        pointOfInterest.longitude = openStreetMapElement.longitude

        return pointOfInterest
    }

    // MARK: Orphans

    func deleteOrphans(syncedObjects: [PointOfInterest], realm: Realm) {
        // List existing objects
        var orphanedObjects: Set<PointOfInterest>
        switch scope {
        case .all:
            orphanedObjects = Set(PointOfInterest.all()(realm))
        case .single:
            orphanedObjects = Set()
        }

        orphanedObjects = orphanedObjects.filter { !syncedObjects.contains($0) }

        if !orphanedObjects.isEmpty {
            orphanedObjects.forEach { $0.deleted = true }
            Logger.info("Flagged \(orphanedObjects.count) \(PointOfInterest.self)(s) for deletion")
        }
    }

}
