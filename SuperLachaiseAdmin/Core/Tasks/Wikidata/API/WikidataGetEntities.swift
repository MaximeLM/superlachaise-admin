//
//  WikidataGetEntities.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 10/12/2017.
//

import Foundation
import RxSwift

final class WikidataGetEntities {

    let endpoint: APIEndpointType

    let wikidataIds: [String]
    let languages: [String]

    // MARK: Init

    init(endpoint: APIEndpointType, wikidataIds: [String], languages: [String]) {
        self.endpoint = endpoint
        self.wikidataIds = wikidataIds.uniqueValues()
        self.languages = languages
    }

    // MARK: Execution

    func asSingle() -> Single<[WikidataEntity]> {
        return Observable.from(wikidataIds.chunked(by: 50))
            .flatMap(self.chunkEntities)
            .reduce([], accumulator: self.mergeEntities)
            .asSingle()
    }

}

private extension WikidataGetEntities {

    func chunkRequest(wikidataIdsChunk: [String]) throws -> URLRequest {
        guard var components = URLComponents(url: endpoint.baseURL, resolvingAgainstBaseURL: false) else {
            throw WikidataGetEntitiesError.invalidBaseURL(endpoint.baseURL)
        }
        let props = ["labels", "descriptions", "claims", "sitelinks"]
        components.queryItems = [
            URLQueryItem(name: "action", value: "wbgetentities"),
            URLQueryItem(name: "format", value: "json"),
            URLQueryItem(name: "ids", value: wikidataIdsChunk.joined(separator: "|")),
            URLQueryItem(name: "languages", value: languages.joined(separator: "|")),
            URLQueryItem(name: "props", value: props.joined(separator: "|")),
        ]
        guard let url = components.url else {
            throw WikidataGetEntitiesError.invalidComponents(components)
        }
        return URLRequest(url: url)
    }

    func chunkEntities(wikidataIdsChunk: [String]) throws -> Single<[WikidataEntity]> {
        let request = try self.chunkRequest(wikidataIdsChunk: wikidataIdsChunk)
        return endpoint.data(request: request)
            .map { try JSONDecoder().decode(WikidataGetEntitiesResult.self, from: $0) }
            .map { result in
                if let warnings = result.warnings {
                    warnings.forEach { keyValue1 in
                        keyValue1.value.forEach { keyValue2 in
                            Logger.warning("[\(keyValue1.key) - \(keyValue2.key)] \(keyValue2.value)")
                        }
                    }
                }
                if let error = result.error {
                    throw error
                }
                guard let entities = result.entities else {
                    throw WikidataGetEntitiesError.noEntities
                }
                guard entities.count == wikidataIdsChunk.count else {
                    throw WikidataGetEntitiesError.missingEntities
                }
                return Array(entities.values)
            }
            .catchError { error in
                guard let resultError = error as? WikidataGetEntitiesResultError,
                    resultError.code == "no-such-entity",
                    let id = resultError.id,
                    let index = wikidataIdsChunk.index(of: id) else {
                        throw error
                }
                Logger.warning(resultError.info)
                var updatedChunk = wikidataIdsChunk
                updatedChunk.remove(at: index)
                return try self.chunkEntities(wikidataIdsChunk: updatedChunk)
            }
    }

    func mergeEntities(entities: [WikidataEntity], chunkEntities: [WikidataEntity]) -> [WikidataEntity] {
        var entities = entities
        entities.append(contentsOf: chunkEntities)
        Logger.debug("\(entities.count)/\(wikidataIds.count)")
        return entities
    }

}

private enum WikidataGetEntitiesError: Error {
    case invalidBaseURL(URL)
    case invalidComponents(URLComponents)
    case noEntities
    case missingEntities
}

private struct WikidataGetEntitiesResult: Decodable {

    let entities: [String: WikidataEntity]?

    let error: WikidataGetEntitiesResultError?
    let warnings: [String: [String: String]]?

}

private struct WikidataGetEntitiesResultError: Decodable, Error {
    let code: String
    let info: String
    let id: String?
}
