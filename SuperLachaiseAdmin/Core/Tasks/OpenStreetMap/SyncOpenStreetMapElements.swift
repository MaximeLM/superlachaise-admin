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

    func asSingle() -> Single<Void> {
        return openStreetMapElements()
            .flatMap(self.deleteOrphans)
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

    func openStreetMapElements() -> Single<[String]> {
        return overpassElements()
            .flatMap(self.saveOpenStreetMapElements)
            .do(onNext: { Logger.info("Fetched \($0.count) primary \(OpenStreetMapElement.self)(s)") })
    }

    func saveOpenStreetMapElements(overpassElements: [OverpassElement]) -> Single<[String]> {
        return Realm.async(dispatchQueue: realmDispatchQueue) { realm in
            try realm.write {
                try self.saveOpenStreetMapElements(overpassElements: overpassElements, realm: realm)
            }
        }
    }

    func saveOpenStreetMapElements(overpassElements: [OverpassElement], realm: Realm) throws -> [String] {
        return try overpassElements.flatMap { overpassElement in
            try self.openStreetMapElement(overpassElement: overpassElement, realm: realm)?.rawOpenStreetMapId
        }
    }

    func openStreetMapElement(overpassElement: OverpassElement, realm: Realm) throws -> OpenStreetMapElement? {
        // OpenStreetMapId
        guard let elementType = OpenStreetMapElementType(rawValue: overpassElement.type) else {
            throw OpenStreetMapError.invalidElementType(overpassElement.type)
        }
        let openStreetMapId = OpenStreetMapId(elementType: elementType, numericId: overpassElement.id)
        guard !config.ignoredElements.contains(openStreetMapId) else {
            return nil
        }
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
        let wikidataTags = ["wikidata", "subject:wikidata"]
        let wikidataId = wikidataTags.flatMap { overpassElement.tags[$0] }.first
        if wikidataId == nil {
            Logger.warning("\(OpenStreetMapElement.self) \(openStreetMapElement) has no wikidata ID")
        }
        openStreetMapElement.wikidataId = wikidataId

        return openStreetMapElement
    }

    enum OpenStreetMapError: Error {
        case invalidElementType(String)
        case coordinateNotFound(OpenStreetMapId)
        case centerNotFound(OpenStreetMapId)
    }

    // MARK: Orphans

    func deleteOrphans(fetchedRawOpenStreetMapIds: [String]) -> Single<Void> {
        return Realm.async(dispatchQueue: realmDispatchQueue) { realm in
            try realm.write {
                try self.deleteOrphans(fetchedRawOpenStreetMapIds: fetchedRawOpenStreetMapIds, realm: realm)
            }
        }
    }

    func deleteOrphans(fetchedRawOpenStreetMapIds: [String], realm: Realm) throws {
        // List existing objects
        var orphanedObjects: Set<OpenStreetMapElement>
        switch scope {
        case .all:
            orphanedObjects = Set(OpenStreetMapElement.all()(realm))
        case .list:
            orphanedObjects = Set()
        }

        orphanedObjects = orphanedObjects.filter { !fetchedRawOpenStreetMapIds.contains($0.rawOpenStreetMapId) }

        if !orphanedObjects.isEmpty {
            orphanedObjects.forEach { $0.deleted = true }
            Logger.info("Flagged \(orphanedObjects.count) \(OpenStreetMapElement.self)(s) for deletion")
        }
    }

}
