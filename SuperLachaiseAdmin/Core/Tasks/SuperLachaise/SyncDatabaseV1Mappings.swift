//
//  SyncDatabaseV1Mappings.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 28/03/2018.
//

import CoreData
import Foundation
import RxSwift

final class SyncDatabaseV1Mappings: Task {

    enum Scope: CustomStringConvertible {

        case all
        case single(id: Int32)

        var description: String {
            switch self {
            case .all:
                return "all"
            case let .single(id):
                return "\(id)"
            }
        }

    }

    let scope: Scope
    let config: SuperLachaiseConfig
    let performInBackground: Single<NSManagedObjectContext>

    init(scope: Scope, config: SuperLachaiseConfig, performInBackground: Single<NSManagedObjectContext>) {
        self.scope = scope
        self.config = config
        self.performInBackground = performInBackground
    }

    var description: String {
        return "\(type(of: self))"
    }

    // MARK: Execution

    func asSingle() -> Single<Void> {
        return performInBackground.map { context in
            try context.write {
                let databaseV1Mappings = try self.syncDatabaseV1Mappings(context: context)
                try self.deleteOrphans(fetchedIds: databaseV1Mappings.map { $0.id }, context: context)
            }
        }
    }

}

private extension SyncDatabaseV1Mappings {

    func syncDatabaseV1Mappings(context: NSManagedObjectContext) throws -> [DatabaseV1Mapping] {
        guard let sourceURL = Bundle.main.url(forResource: "database_v1", withExtension: "json") else {
            throw SyncDatabaseV1MappingsError.sourceJsonNotFound
        }
        var monuments = try JSONDecoder().decode([DatabaseV1Monument].self, from: Data(contentsOf: sourceURL))

        switch self.scope {
        case .all:
            break
        case let .single(id):
            monuments = monuments.filter { $0.id == id }
        }

        let customMappings = try self.customMappings(context: context)
        return monuments.map { monument in
            syncDatabaseV1Mapping(monument: monument, customMappings: customMappings, context: context)
        }
    }

    func syncDatabaseV1Mapping(monument: DatabaseV1Monument,
                               customMappings: [Int32: WikidataEntry],
                               context: NSManagedObjectContext) -> DatabaseV1Mapping {
        let databaseV1Mapping = context.findOrCreate(DatabaseV1Mapping.self, key: monument.id)
        databaseV1Mapping.pointOfInterest = pointOfInterest(
            monument: monument, customMappings: customMappings, context: context)
        return databaseV1Mapping
    }

    func pointOfInterest(monument: DatabaseV1Monument,
                         customMappings: [Int32: WikidataEntry],
                         context: NSManagedObjectContext) -> PointOfInterest? {
        guard let wikidataEntry = self.wikidataEntry(
            monument: monument, customMappings: customMappings, context: context) else {
                return nil
        }
        let sourceName = monument.name
        let destName = context.find(WikidataLocalizedEntry.self,
                                    key: (wikidataEntry: wikidataEntry, language: "fr"))?.name
        if let destName = destName, sourceName != destName {
            Logger.warning("Name mismatch: \(sourceName) - \(destName)")
        }
        guard let pointOfInterest = context.find(PointOfInterest.self, key: wikidataEntry.id) else {
            Logger.error("No point of interest element for \(wikidataEntry.id)")
            return nil
        }
        return pointOfInterest
    }

    func wikidataEntry(monument: DatabaseV1Monument,
                       customMappings: [Int32: WikidataEntry],
                       context: NSManagedObjectContext) -> WikidataEntry? {
        if let customValue = customMappings[monument.id] {
            return customValue
        }

        let numericId = monument.nodeOSM.id
        let node = context.find(OpenStreetMapElement.self,
                                key: OpenStreetMapId(elementType: .node, numericId: numericId))
        let way = context.find(OpenStreetMapElement.self,
                               key: OpenStreetMapId(elementType: .way, numericId: numericId))
        let relation = context.find(OpenStreetMapElement.self,
                                    key: OpenStreetMapId(elementType: .relation, numericId: numericId))
        let existingElements = [node, way, relation].compactMap { $0 }

        guard !existingElements.isEmpty else {
            Logger.error("No OpenStreetMap element for \(monument)")
            return nil
        }
        guard existingElements.count == 1, let openStreetMapElement = existingElements.first else {
            Logger.error("More than 1 OpenStreetMap element for \(monument)")
            return nil
        }
        guard let wikidataEntry = openStreetMapElement.wikidataEntry else {
            Logger.error("No wikidataEntry element for \(openStreetMapElement)")
            return nil
        }
        return wikidataEntry
    }

    func customMappings(context: NSManagedObjectContext) throws -> [Int32: WikidataEntry] {
        guard let customMappings = config.databaseV1CustomMappings else {
            return [:]
        }
        return try Dictionary(customMappings.map {
            guard let monumentId = Int32($0.key) else {
                throw SyncDatabaseV1MappingsError.invalidCustomMappingId($0.key)
            }
            guard let wikidataEntry = context.find(WikidataEntry.self, key: $0.value) else {
                throw SyncDatabaseV1MappingsError.customMappingWikidataEntryNotFound($0.value)
            }
            return (monumentId, wikidataEntry)
        }, uniquingKeysWith: {
                throw SyncDatabaseV1MappingsError.duplicateCustomMapping($0.id, $1.id)
        })
    }

    // MARK: Orphans

    func deleteOrphans(fetchedIds: [Int32], context: NSManagedObjectContext) throws {
        // List existing objects
        var orphanedObjects: Set<DatabaseV1Mapping>
        switch scope {
        case .all:
            orphanedObjects = Set(context.objects(DatabaseV1Mapping.self).fetch())
        case .single:
            orphanedObjects = Set()
        }

        orphanedObjects = orphanedObjects.filter { !fetchedIds.contains($0.id) }

        if !orphanedObjects.isEmpty {
            Logger.info("Deleting \(orphanedObjects.count) \(DatabaseV1Mapping.self)(s)")
            orphanedObjects.forEach { context.delete($0) }
        }
    }

}

private struct DatabaseV1Monument: Decodable {

    let id: Int32
    let name: String
    let nodeOSM: DatabaseV1NodeOSM

    enum CodingKeys: String, CodingKey {
        case id, name = "nom", nodeOSM = "node_osm"
    }

}

private struct DatabaseV1NodeOSM: Decodable {
    let id: Int64
}

enum SyncDatabaseV1MappingsError: Error {
    case sourceJsonNotFound
    case invalidCustomMappingId(String)
    case customMappingWikidataEntryNotFound(String)
    case duplicateCustomMapping(String, String)
}
