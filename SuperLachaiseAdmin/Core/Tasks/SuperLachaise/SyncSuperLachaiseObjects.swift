//
//  SyncSuperLachaiseObjects.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 24/03/2018.
//

import Foundation

import Foundation
import RealmSwift
import RxSwift

final class SyncSuperLachaiseObjects: Task {

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
                self.prepareOrphans(realm: realm)
                self.syncPointsOfInterest(realm: realm)
            }
        }
    }

    // MARK: Private properties

    private let realmDispatchQueue = DispatchQueue(label: "SyncSuperLachaiseObjects.realm")

}

private extension SyncSuperLachaiseObjects {

    func prepareOrphans(realm: Realm) {
        switch self.scope {
        case .all:
            PointOfInterest.all()(realm).setValue(true, forKey: "deleted")
            Entry.all()(realm).setValue(true, forKey: "deleted")
        case .single:
            break
        }
    }

    func syncPointsOfInterest(realm: Realm) {
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
            duplicate.key.deleted = true
        }
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

}
