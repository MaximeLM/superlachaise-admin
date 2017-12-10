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

    enum RequestError: Error {
        case invalidBaseURL(URL)
        case invalidComponents(URLComponents)
    }

    init(endpoint: APIEndpointType, wikidataIds: [String], languages: [String]) {
        self.endpoint = endpoint
        self.wikidataIds = wikidataIds
        self.languages = languages
    }

    // MARK: Execution

    func asObservable() -> Observable<Void> {
        return Observable.from(wikidataIds.chunked(by: 50))
            .flatMap(self.chunkResult)
            .map { _ in }
    }

    // MARK: Chunk query

    private func chunkRequest(wikidataIdsChunk: [String]) throws -> URLRequest {
        guard var components = URLComponents(url: endpoint.baseURL, resolvingAgainstBaseURL: false) else {
            throw RequestError.invalidBaseURL(endpoint.baseURL)
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
            throw RequestError.invalidComponents(components)
        }
        return URLRequest(url: url)
    }

    private func chunkResult(wikidataIdsChunk: [String]) -> Single<WikidataGetEntitiesChunkResult> {
        do {
            let request = try self.chunkRequest(wikidataIdsChunk: wikidataIdsChunk)
            return endpoint.data(request: request)
                .map { try JSONDecoder().decode(WikidataGetEntitiesChunkResult.self, from: $0) }
        } catch {
            return Single.error(error)
        }
    }

}

private struct WikidataGetEntitiesChunkResult: Decodable {

    let entities: [String: WikidataEntityResult]

}
