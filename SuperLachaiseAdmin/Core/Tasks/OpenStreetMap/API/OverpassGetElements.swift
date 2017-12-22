//
//  OverpassGetElements.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 10/12/2017.
//

import Foundation
import RxSwift

final class OverpassGetElements {

    let endpoint: APIEndpointType

    let subqueries: [String]

    // MARK: Init

    convenience init(endpoint: APIEndpointType, boundingBox: BoundingBox, fetchedTags: [String]) {
        let boundingBoxString = """
        \(boundingBox.minLatitude), \(boundingBox.minLongitude), \
        \(boundingBox.maxLatitude), \(boundingBox.maxLongitude)
        """

        // Create a subquery for each combination of type and tag
        let elementTypes: [OpenStreetMapElementType] = [.node, .way, .relation]
        let subqueries = elementTypes.flatMap { elementType in
            fetchedTags.map { tag in
                // ex. "node[historic=tomb](48.8575,2.3877,48.8649,2.4006)"
                "\(elementType.rawValue)[\(tag)](\(boundingBoxString));"
            }
        }

        self.init(endpoint: endpoint, subqueries: subqueries)
    }

    convenience init(endpoint: APIEndpointType, openStreetMapIds: [OpenStreetMapId]) {
        // Create a subquery for each element
        let subqueries = openStreetMapIds.map { openStreetMapId in
            // ex. "node(123456)"
            "\(openStreetMapId.elementType.rawValue)(\(openStreetMapId.numericId));"
        }

        self.init(endpoint: endpoint, subqueries: subqueries)
    }

    init(endpoint: APIEndpointType, subqueries: [String]) {
        self.endpoint = endpoint
        self.subqueries = subqueries
    }

    // MARK: Execution

    func asSingle() -> Single<[OverpassElement]> {
        do {
            let request = try self.request()
            return endpoint.data(request: request)
                .map { try JSONDecoder().decode(OverpassGetElementsResult.self, from: $0).elements }
        } catch {
            return Single.error(error)
        }
    }

}

private extension OverpassGetElements {

    func request() throws -> URLRequest {
        let interpreterURL = endpoint.baseURL.appendingPathComponent("interpreter")
        var request = URLRequest(url: interpreterURL)
        request.httpMethod = "POST"

        var queryLines = subqueries
        queryLines.insert("[out:json];(", at: 0)
        queryLines.append(");out center;")
        let body = queryLines.joined(separator: "\n")
        guard let httpBody = body.data(using: .utf8) else {
            throw OverpassGetElementsError.invalidBody(body)
        }
        request.httpBody = httpBody

        return request
    }

}

private struct OverpassGetElementsResult: Decodable {

    let elements: [OverpassElement]

}

private enum OverpassGetElementsError: Error {
    case invalidBody(String)
}
