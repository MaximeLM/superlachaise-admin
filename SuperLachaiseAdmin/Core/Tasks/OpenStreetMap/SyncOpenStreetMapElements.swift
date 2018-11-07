//
//  SyncOpenStreetMapElements.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 28/11/2017.
//

import CoreData
import Foundation
import RxSwift

final class SyncOpenStreetMapElements: Task {

    enum Scope: CustomStringConvertible {

        case all
        case single(openStreetMapId: OpenStreetMapId)

        var description: String {
            switch self {
            case .all:
                return "all"
            case let .single(openStreetMapId):
                return openStreetMapId.description
            }
        }

    }

    let scope: Scope

    let config: OpenStreetMapConfig
    let endpoint: APIEndpointType
    let performInContext: Single<NSManagedObjectContext>

    init(scope: Scope,
         config: OpenStreetMapConfig,
         endpoint: APIEndpointType,
         performInContext: Single<NSManagedObjectContext>) {
        self.scope = scope
        self.config = config
        self.endpoint = endpoint
        self.performInContext = performInContext
    }

    var description: String {
        return "\(type(of: self)) (\(scope.description))"
    }

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
        case let .single(openStreetMapId):
            getElements = OverpassGetElements(endpoint: endpoint, openStreetMapIds: [openStreetMapId])
        }
        return getElements.asSingle()
    }

    // MARK: OpenStreetMap elements

    func openStreetMapElements() -> Single<[String]> {
        return overpassElements()
            .flatMap(self.saveOpenStreetMapElements)
            .do(onSuccess: { Logger.info("Fetched \($0.count) \(OpenStreetMapElement.self)(s)") })
    }

    func saveOpenStreetMapElements(overpassElements: [OverpassElement]) -> Single<[String]> {
        return performInContext.map { context in
            try context.write {
                try self.saveOpenStreetMapElements(overpassElements: overpassElements, context: context)
            }
        }
    }

    func saveOpenStreetMapElements(overpassElements: [OverpassElement],
                                   context: NSManagedObjectContext) throws -> [String] {
        return try overpassElements.compactMap { overpassElement in
            try self.openStreetMapElement(overpassElement: overpassElement, context: context)?.id
        }
    }

    // MARK: OpenStreetMap element

    func openStreetMapElement(overpassElement: OverpassElement,
                              context: NSManagedObjectContext) throws -> CoreDataOpenStreetMapElement? {
        // OpenStreetMapId
        guard let elementType = OpenStreetMapElementType(rawValue: overpassElement.type) else {
            throw SyncOpenStreetMapElementsError.invalidElementType(overpassElement.type)
        }
        let openStreetMapId = OpenStreetMapId(elementType: elementType, numericId: overpassElement.id)
        let openStreetMapElement = context.findOrCreate(CoreDataOpenStreetMapElement.self, key: openStreetMapId)

        // Coordinate
        switch elementType {
        case .node:
            guard let latitude = overpassElement.lat, let longitude = overpassElement.lon else {
                throw SyncOpenStreetMapElementsError.coordinateNotFound(openStreetMapId)
            }
            openStreetMapElement.latitude = latitude
            openStreetMapElement.longitude = longitude
        case .way, .relation:
            guard let center = overpassElement.center else {
                throw SyncOpenStreetMapElementsError.centerNotFound(openStreetMapId)
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

        // Wikidata entry
        let wikidataTags = ["wikidata", "subject:wikidata"]
        let wikidataId = wikidataTags.compactMap { overpassElement.tags[$0] }.first
        if wikidataId == nil {
            Logger.warning("\(OpenStreetMapElement.self) \(openStreetMapElement) has no wikidata ID")
        }
        let wikidataEntry = wikidataId.map { context.findOrCreate(CoreDataWikidataEntry.self, key: $0) }
        openStreetMapElement.wikidataEntry = wikidataEntry

        return openStreetMapElement
    }

    // MARK: Orphans

    func deleteOrphans(fetchedIds: [String]) -> Single<Void> {
        return performInContext.map { context in
            try context.write {
                try self.deleteOrphans(fetchedIds: fetchedIds, context: context)
            }
        }
    }

    func deleteOrphans(fetchedIds: [String], context: NSManagedObjectContext) throws {
        // List existing objects
        var orphanedObjects: Set<CoreDataOpenStreetMapElement>
        switch scope {
        case .all:
            orphanedObjects = Set(context.objects(CoreDataOpenStreetMapElement.self).fetch())
        case .single:
            orphanedObjects = Set()
        }

        orphanedObjects = orphanedObjects.filter { !fetchedIds.contains($0.id) }

        if !orphanedObjects.isEmpty {
            Logger.info("Deleting \(orphanedObjects.count) \(CoreDataOpenStreetMapElement.self)(s)")
            orphanedObjects.forEach { context.delete($0) }
        }
    }

}

enum SyncOpenStreetMapElementsError: Error {
    case invalidElementType(String)
    case coordinateNotFound(OpenStreetMapId)
    case centerNotFound(OpenStreetMapId)
}
