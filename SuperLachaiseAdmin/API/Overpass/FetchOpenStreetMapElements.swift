//
//  FetchOpenStreetMapElements.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 28/11/2017.
//

import Foundation
import RealmSwift
import RxSwift

final class FetchOpenStreetMapElements: AsyncTask {

    private let scope: Scope
    private let endpoint: APIEndpointType

    init(scope: Scope, endpoint: APIEndpointType = APIEndpoint.overpass) {
        self.scope = scope
        self.endpoint = endpoint
    }

    // MARK: Types

    typealias BoundingBox = (minLatitude: Double, minLongitude: Double, maxLatitude: Double, maxLongitude: Double)

    enum Scope {
        case all(boundingBox: BoundingBox, tags: [String])
        case list([OpenStreetMapId])
    }

    enum RequestError: Error {
        case invalidBody(String)
    }

    // MARK: Execution

    func execute(_ observer: @escaping (CompletableEvent) -> Void) throws -> Disposable {
        return try fetchData()
            .map(self.results)
            .flatMap(self.save)
            .toCompletable()
            .subscribe(observer)
    }

    // MARK: Request

    private func fetchData() throws -> Single<Data> {
        let request = try self.request()
        return endpoint.data(request: request)
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
        case let .all(boundingBox, tags):
            let boundingBoxString = """
            \(boundingBox.minLatitude), \(boundingBox.minLongitude), \
            \(boundingBox.maxLatitude), \(boundingBox.maxLongitude)
            """

            // Create a subquery for each combination of type and tag
            let elementTypes: [OpenStreetMapElementType] = [.node, .way, .relation]
            return elementTypes.flatMap { elementType in
                tags.map { tag in
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

    // MARK: Save

    private func save(results: OverpassResults) -> Single<Void> {
        return Realm.background { realm in

        }
    }

}
