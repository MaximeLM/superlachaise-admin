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

    enum Scope {
        case all
        case list(openStreetMapIds: [OpenStreetMapId])
    }

    let scope: Scope

    let config: OpenStreetMapConfig
    let endpoint: APIEndpointType

    init(scope: Scope, config: OpenStreetMapConfig, endpoint: APIEndpointType) {
        self.scope = scope
        self.config = config
        self.endpoint = endpoint
    }

    private let realmDispatchQueue = DispatchQueue(label: "SyncOpenStreetMapElements.realm")

    // MARK: Execution

    func asCompletable() -> Completable {
        return overpassElements()
            .flatMap(self.openStreetMapElements)
            .asObservable().ignoreElements()
    }

}

private extension SyncOpenStreetMapElements {

    // MARK: Overpass Elements

    func overpassElements() -> Single<[OverpassElement]> {
        let getElements: OverpassGetElements
        switch scope {
        case .all:
            getElements = OverpassGetElements(endpoint: endpoint,
                                              boundingBox: config.boundingBox,
                                              fetchedTags: config.fetchedTags)
        case let .list(openStreetMapIds):
            getElements = OverpassGetElements(endpoint: endpoint, openStreetMapIds: openStreetMapIds)
        }
        return getElements.asSingle()
    }

    // MARK: OpenStreetMap elements

    enum OpenStreetMapError: Error {
        case invalidElementType(String)
        case coordinateNotFound(OpenStreetMapId)
        case centerNotFound(OpenStreetMapId)
    }

    func openStreetMapElements(overpassElements: [OverpassElement]) -> Single<[OpenStreetMapElement]> {
        return Realm.async(dispatchQueue: realmDispatchQueue) { realm in
            return try realm.write {
                try self.openStreetMapElements(overpassElements: overpassElements, realm: realm)
            }
        }
    }

    func openStreetMapElements(overpassElements: [OverpassElement], realm: Realm) throws -> [OpenStreetMapElement] {
        // List existing objects before updating
        var orphanedObjects: Set<OpenStreetMapElement>
        switch scope {
        case .all:
            orphanedObjects = Set(OpenStreetMapElement.all()(realm))
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
            orphanedObjects.forEach { $0.deleted = true }
            Logger.info("Flagged \(orphanedObjects.count) \(OpenStreetMapElement.self)(s) for deletion")
        }

        return fetchedObjects
    }

    func openStreetMapElement(overpassElement: OverpassElement, realm: Realm) throws -> OpenStreetMapElement {
        // OpenStreetMapId
        guard let elementType = OpenStreetMapElementType(rawValue: overpassElement.type) else {
            throw OpenStreetMapError.invalidElementType(overpassElement.type)
        }
        let openStreetMapId = OpenStreetMapId(elementType: elementType, numericId: overpassElement.id)
        let openStreetMapElement = OpenStreetMapElement.findOrCreate(openStreetMapId: openStreetMapId)(realm)
        openStreetMapElement.deleted = false

        // Coordinate
        switch elementType {
        case .node:
            guard let latitude = overpassElement.lat, let longitude = overpassElement.lon else {
                throw OpenStreetMapError.coordinateNotFound(openStreetMapId)
            }
            openStreetMapElement.latitude = latitude
            openStreetMapElement.longitude = longitude
        case .way, .relation:
            guard let center = overpassElement.center else {
                throw OpenStreetMapError.centerNotFound(openStreetMapId)
            }
            openStreetMapElement.latitude = center.lat
            openStreetMapElement.longitude = center.lon
        }

        // Name
        let name = overpassElement.tags["name"]
        if name == nil {
            Logger.warning("\(OpenStreetMapElement.self) \(openStreetMapElement) has no name")
        }
        openStreetMapElement.name = name

        // Wikidata Id
        let wikidataId = overpassElement.tags["wikidata"] ?? overpassElement.tags["subject:wikidata"]
        if wikidataId == nil {
            Logger.warning("\(OpenStreetMapElement.self) \(openStreetMapElement) has no wikidata ID")
        }
        openStreetMapElement.wikidataId = wikidataId

        return openStreetMapElement
    }

}
