//
//  SyncDatabaseV1Mappings.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 28/03/2018.
//

import Foundation
import RealmSwift
import RxSwift

final class SyncDatabaseV1Mappings: Task {

    enum Scope: CustomStringConvertible {

        case all
        case single(monumentId: Int)

        var description: String {
            switch self {
            case .all:
                return "all"
            case let .single(monumentId):
                return "\(monumentId)"
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
        return "\(type(of: self))"
    }

    // MARK: Execution

    func asSingle() -> Single<Void> {
        return Realm.async(dispatchQueue: realmDispatchQueue) { realm in
            try realm.write {
                try self.syncDatabaseV1Mappings(realm: realm)
            }
        }
    }

    // MARK: Private properties

    private let realmDispatchQueue = DispatchQueue(label: "SyncDatabaseV1Mappings.realm")

}

private extension SyncDatabaseV1Mappings {

    func prepareOrphans(realm: Realm) {
        switch self.scope {
        case .all:
            DatabaseV1Mapping.all()(realm).setValue(true, forKey: "isDeleted")
        case .single:
            break
        }
    }

    func syncDatabaseV1Mappings(realm: Realm) throws {
        guard let sourceURL = Bundle.main.url(forResource: "database_v1", withExtension: "json") else {
            throw SyncDatabaseV1MappingsError.sourceJsonNotFound
        }
        var monuments = try JSONDecoder().decode([DatabaseV1Monument].self, from: Data(contentsOf: sourceURL))

        switch self.scope {
        case .all:
            break
        case let .single(monumentId):
            monuments = monuments.filter { $0.id == monumentId }
        }

        let customMappings = try self.customMappings(realm: realm)
        for monument in monuments {
            syncDatabaseV1Mapping(monument: monument, customMappings: customMappings, realm: realm)
        }
    }

    func syncDatabaseV1Mapping(monument: DatabaseV1Monument, customMappings: [Int: WikidataEntry], realm: Realm) {
        let databaseV1Mapping = DatabaseV1Mapping.findOrCreate(monumentId: monument.id)(realm)
        databaseV1Mapping.isDeleted = false
        databaseV1Mapping.pointOfInterest = pointOfInterest(
            monument: monument, customMappings: customMappings, realm: realm)
    }

    func pointOfInterest(
        monument: DatabaseV1Monument, customMappings: [Int: WikidataEntry], realm: Realm) -> PointOfInterest? {
        guard let wikidataEntry = self.wikidataEntry(
            monument: monument, customMappings: customMappings, realm: realm) else {
                return nil
        }
        let sourceName = monument.name
        let destName = wikidataEntry.localization(language: "fr")?.name
        if let destName = destName, sourceName != destName {
            Logger.warning("Name mismatch: \(sourceName) - \(destName)")
        }
        guard let pointOfInterest = PointOfInterest.find(id: wikidataEntry.wikidataId)(realm) else {
            Logger.error("No point of interest element for \(wikidataEntry.wikidataId)")
            return nil
        }
        return pointOfInterest
    }

    func wikidataEntry(
        monument: DatabaseV1Monument, customMappings: [Int: WikidataEntry], realm: Realm) -> WikidataEntry? {
        if let customValue = customMappings[monument.id] {
            return customValue
        }

        let numericId = monument.nodeOSM.id
        let node = OpenStreetMapElement
            .find(openStreetMapId: OpenStreetMapId(elementType: .node, numericId: numericId))(realm)
        let way = OpenStreetMapElement
            .find(openStreetMapId: OpenStreetMapId(elementType: .way, numericId: numericId))(realm)
        let relation = OpenStreetMapElement
            .find(openStreetMapId: OpenStreetMapId(elementType: .relation, numericId: numericId))(realm)
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

    func customMappings(realm: Realm) throws -> [Int: WikidataEntry] {
        guard let customMappings = config.databaseV1CustomMappings else {
            return [:]
        }
        return try Dictionary(customMappings.map {
            guard let monumentId = Int($0.key) else {
                throw SyncDatabaseV1MappingsError.invalidCustomMappingId($0.key)
            }
            guard let wikidataEntry = WikidataEntry.find(wikidataId: $0.value)(realm) else {
                throw SyncDatabaseV1MappingsError.customMappingWikidataEntryNotFound($0.value)
            }
            return (monumentId, wikidataEntry)
        }, uniquingKeysWith: {
            throw SyncDatabaseV1MappingsError.duplicateCustomMapping($0.wikidataId, $1.wikidataId)
        })
    }

}

private struct DatabaseV1Monument: Decodable {

    let id: Int
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
