//
//  SyncOpenStreetMapElements.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 28/11/2017.
//

import Foundation
import RealmSwift
import RxSwift

final class SyncOpenStreetMapElements: Task {

    let scope: Scope

    let endpoint: APIEndpointType

    init(scope: Scope, endpoint: APIEndpointType) {
        self.scope = scope
        self.endpoint = endpoint
    }

    private let realmDispatchQueue = DispatchQueue(label: "SyncOpenStreetMapElements.realm")

    // MARK: Types

    enum Scope {
        case all(boundingBox: BoundingBox, fetchedTags: [String])
        case list(openStreetMapIds: [OpenStreetMapId])
    }

    // MARK: Execution

    func asCompletable() -> Completable {
        return getElements().asObservable()
            .flatMap(self.sync)
            .asObservable().ignoreElements()
    }

    // MARK: Requests

    private func getElements() -> OverpassGetElements {
        switch scope {
        case let .all(boundingBox, fetchedTags):
            return OverpassGetElements(endpoint: endpoint, boundingBox: boundingBox, fetchedTags: fetchedTags)
        case let .list(openStreetMapIds):
            return OverpassGetElements(endpoint: endpoint, openStreetMapIds: openStreetMapIds)
        }
    }

    // MARK: Sync

    enum SyncError: Error {
        case invalidElementType(String)
        case coordinateNotFound(OpenStreetMapId)
        case centerNotFound(OpenStreetMapId)
    }

    private func sync(overpassElements: [OverpassElement]) throws -> Single<Void> {
        return Realm.async(dispatchQueue: realmDispatchQueue) { realm in
            try realm.write {
                let openStreetMapElements = try self.openStreetMapElements(overpassElements: overpassElements,
                                                                           realm: realm)
                _ = try self.superLachaisePOIs(openStreetMapElements: openStreetMapElements, realm: realm)
            }
        }
    }

    private func openStreetMapElements(overpassElements: [OverpassElement],
                                       realm: Realm) throws -> [OpenStreetMapElement] {
        // List existing objects before updating
        var orphanedObjects: Set<OpenStreetMapElement>
        switch scope {
        case .all:
            orphanedObjects = Set(realm.objects(OpenStreetMapElement.self))
        case .list:
            orphanedObjects = Set()
        }

        let fetchedObjects = try overpassElements.map { overpassElement -> OpenStreetMapElement in
            let fetchedObject = try self.openStreetMapElement(overpassElement: overpassElement, realm: realm)
            orphanedObjects.remove(fetchedObject)
            return fetchedObject
        }
        Logger.info("Fetched \(fetchedObjects.count) \(OpenStreetMapElement.self)(s)")

        if !orphanedObjects.isEmpty {
            orphanedObjects.forEach { $0.toBeDeleted = true }
            Logger.info("Flagged \(orphanedObjects.count) \(OpenStreetMapElement.self)(s) for deletion")
        }

        return fetchedObjects
    }

    private func openStreetMapElement(overpassElement: OverpassElement, realm: Realm) throws -> OpenStreetMapElement {
        // OpenStreetMapId
        guard let elementType = OpenStreetMapElementType(rawValue: overpassElement.type) else {
            throw SyncError.invalidElementType(overpassElement.type)
        }
        let openStreetMapId = OpenStreetMapId(elementType: elementType, numericId: overpassElement.id)
        let openStreetMapElement = realm.findOrCreateObject(ofType: OpenStreetMapElement.self,
                                                            forPrimaryKey: openStreetMapId.rawValue)
        openStreetMapElement.toBeDeleted = false

        // Coordinate
        switch elementType {
        case .node:
            guard let latitude = overpassElement.lat, let longitude = overpassElement.lon else {
                throw SyncError.coordinateNotFound(openStreetMapId)
            }
            openStreetMapElement.latitude = latitude
            openStreetMapElement.longitude = longitude
        case .way, .relation:
            guard let center = overpassElement.center else {
                throw SyncError.centerNotFound(openStreetMapId)
            }
            openStreetMapElement.latitude = center.lat
            openStreetMapElement.longitude = center.lon
        }

        // Name
        let name = overpassElement.tags["name"]
        if name == nil {
            Logger.warning("OpenStreetMapElement \(openStreetMapElement) has no name")
        }
        openStreetMapElement.name = name

        // Wikidata Id
        let wikidataId = overpassElement.tags["wikidata"]
        if wikidataId == nil {
            Logger.warning("OpenStreetMapElement \(openStreetMapElement) has no wikidata ID")
        }
        openStreetMapElement.wikidataId = wikidataId

        return openStreetMapElement
    }

    private func superLachaisePOIs(openStreetMapElements: [OpenStreetMapElement],
                                   realm: Realm) throws -> [SuperLachaisePOI] {
        // List existing objects before updating
        var orphanedObjects: Set<SuperLachaisePOI>
        switch scope {
        case .all:
            orphanedObjects = Set(realm.objects(SuperLachaisePOI.self))
        case .list:
            orphanedObjects = Set()
        }

        let fetchedObjects = try openStreetMapElements.flatMap { openStreetMapElement -> SuperLachaisePOI? in
            if let fetchedObject = try self.superLachaisePOI(openStreetMapElement: openStreetMapElement, realm: realm) {
                orphanedObjects.remove(fetchedObject)
                return fetchedObject
            } else {
                return nil
            }
        }
        Logger.info("Synced \(fetchedObjects.count) \(SuperLachaisePOI.self)(s)")

        if !orphanedObjects.isEmpty {
            orphanedObjects.forEach { $0.toBeDeleted = true }
            Logger.info("Flagged \(orphanedObjects.count) \(SuperLachaisePOI.self)(s) for deletion")
        }

        return fetchedObjects
    }

    private func superLachaisePOI(openStreetMapElement: OpenStreetMapElement,
                                  realm: Realm) throws -> SuperLachaisePOI? {
        // Wikidata Id
        guard let wikidataId = openStreetMapElement.wikidataId else {
            return nil
        }
        let superLachaisePOI = realm.findOrCreateObject(ofType: SuperLachaisePOI.self,
                                                        forPrimaryKey: wikidataId)
        superLachaisePOI.toBeDeleted = false

        // OpenStreetMap element
        if let existingOpenStreetMapElement = superLachaisePOI.openStreetMapElement,
            existingOpenStreetMapElement != openStreetMapElement {
            Logger.warning("""
                SuperLachaisePOI \(superLachaisePOI) is referenced by OpenStreetMapElements \
                \(existingOpenStreetMapElement) and \(openStreetMapElement)
                """)
        }
        superLachaisePOI.openStreetMapElement = openStreetMapElement

        // Name
        superLachaisePOI.name = openStreetMapElement.name

        return superLachaisePOI
    }

}
