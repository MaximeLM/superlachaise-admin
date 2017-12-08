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

    private let scope: Scope

    private let realmContext: RealmContext
    private let endpoint: APIEndpointType

    init(scope: Scope, realmContext: RealmContext, endpoint: APIEndpointType) {
        self.scope = scope
        self.realmContext = realmContext
        self.endpoint = endpoint
    }

    // MARK: Types

    enum Scope {
        case all(boundingBox: BoundingBox, fetchedTags: [String])
        case list([OpenStreetMapId])
    }

    // MARK: Execution

    func asCompletable() -> Completable {
        return Single.create(self.request)
            .flatMap(self.endpoint.data)
            .map(self.results)
            .flatMap(self.sync)
            .toCompletable()
    }

    // MARK: Request

    enum RequestError: Error {
        case invalidBody(String)
    }

    private func request() throws -> URLRequest {
        let interpreterURL = endpoint.baseURL.appendingPathComponent("interpreter")
        var request = URLRequest(url: interpreterURL)
        request.httpMethod = "POST"

        let body = requestBody()
        guard let httpBody = body.data(using: .utf8) else {
            throw RequestError.invalidBody(body)
        }
        request.httpBody = httpBody

        return request
    }

    private func requestBody() -> String {
        var lines = requestSubqueries()
        lines.insert("[out:json];(", at: 0)
        lines.append(");out center;")
        return lines.joined(separator: "\n")
    }

    private func requestSubqueries() -> [String] {
        switch scope {
        case let .all(boundingBox, fetchedTags):
            let boundingBoxString = """
            \(boundingBox.minLatitude), \(boundingBox.minLongitude), \
            \(boundingBox.maxLatitude), \(boundingBox.maxLongitude)
            """

            // Create a subquery for each combination of type and tag
            let elementTypes: [OpenStreetMapElementType] = [.node, .way, .relation]
            return elementTypes.flatMap { elementType in
                fetchedTags.map { tag in
                    // ex. "node[historic=tomb](48.8575,2.3877,48.8649,2.4006)"
                    "\(elementType.rawValue)[\(tag)](\(boundingBoxString));"
                }
            }
        case let .list(openStreetMapIds):
            // Create a subquery for each element
            return openStreetMapIds.map { openStreetMapId in
                // ex. "node(123456)"
                "\(openStreetMapId.elementType.rawValue)(\(openStreetMapId.numericId));"
            }
        }
    }

    // MARK: Results

    private func results(data: Data) throws -> OverpassResults {
        return try JSONDecoder().decode(OverpassResults.self, from: data)
    }

    // MARK: Sync

    enum SyncError: Error {
        case invalidElementType(String)
        case coordinateNotFound(OpenStreetMapId)
        case centerNotFound(OpenStreetMapId)
    }

    private func sync(results: OverpassResults) throws -> Single<Void> {
        return Realm.async(configuration: realmContext.configuration) { realm in
            try realm.write {
                let openStreetMapElements = try self.openStreetMapElements(results: results, realm: realm)
                _ = try self.superLachaisePOIs(openStreetMapElements: openStreetMapElements, realm: realm)
            }
        }
    }

    private func openStreetMapElements(results: OverpassResults, realm: Realm) throws -> [OpenStreetMapElement] {
        // List existing objects before updating
        var orphanedObjects: Set<OpenStreetMapElement>
        switch scope {
        case .all:
            orphanedObjects = Set(realm.objects(OpenStreetMapElement.self))
        case .list:
            orphanedObjects = Set()
        }

        let fetchedObjects = try results.elements.map { overpassElement -> OpenStreetMapElement in
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
