//
//  WikipediaGetPages.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 22/12/2017.
//

import Foundation
import RxSwift

final class WikipediaGetPages {

    let endpoint: APIEndpointType

    let wikipediaTitles: [String]

    // MARK: Init

    init(endpoint: APIEndpointType, wikipediaTitles: [String]) {
        self.endpoint = endpoint
        self.wikipediaTitles = wikipediaTitles.uniqueValues()
    }

    // MARK: Execution

    func asSingle() -> Single<[WikipediaAPIPage]> {
        return Observable.from(wikipediaTitles.chunked(by: 20))
            .flatMap(self.chunkEntities)
            .reduce([], accumulator: self.mergeEntities)
            .asSingle()
    }

}

private extension WikipediaGetPages {

    func chunkEntities(wikipediaTitlesChunk: [String]) throws -> Single<[WikipediaAPIPage]> {
        let request = try self.chunkRequest(wikipediaTitlesChunk: wikipediaTitlesChunk)
        return endpoint.data(request: request)
            .map { try JSONDecoder().decode(WikipediaGetPagesResult.self, from: $0) }
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
                guard result.continue == nil else {
                    throw WikipediaGetPagesError.hasContinue
                }
                guard let pagesDict = result.query?.pages else {
                    throw WikipediaGetPagesError.noPages
                }
                let pages = Array(pagesDict.values)
                guard pages.count == wikipediaTitlesChunk.count else {
                    throw WikipediaGetPagesError.missingPages
                }
                if let normalized = result.query?.normalized {
                    normalized.forEach { normalization in
                        Logger.warning("Page normalized from \(normalization.from) to \(normalization.to)")
                    }
                }
                return pages.filter { page in
                    if page.missing != nil {
                        Logger.warning("Page \(page.title) is missing")
                        return false
                    } else {
                        return true
                    }
                }
            }
    }

    func chunkRequest(wikipediaTitlesChunk: [String]) throws -> URLRequest {
        guard var components = URLComponents(url: endpoint.baseURL, resolvingAgainstBaseURL: false) else {
            throw WikipediaGetPagesError.invalidBaseURL(endpoint.baseURL)
        }
        let props = ["revisions", "extracts"]
        components.queryItems = [
            URLQueryItem(name: "action", value: "query"),
            URLQueryItem(name: "exintro", value: ""),
            URLQueryItem(name: "format", value: "json"),
            URLQueryItem(name: "prop", value: props.joined(separator: "|")),
            URLQueryItem(name: "rvprop", value: "content"),
            URLQueryItem(name: "titles", value: wikipediaTitlesChunk.joined(separator: "|")),
        ]
        guard let url = components.url else {
            throw WikipediaGetPagesError.invalidComponents(components)
        }
        return URLRequest(url: url)
    }

    func mergeEntities(entities: [WikipediaAPIPage], chunkEntities: [WikipediaAPIPage]) -> [WikipediaAPIPage] {
        var entities = entities
        entities.append(contentsOf: chunkEntities)
        Logger.debug("\(entities.count)/\(wikipediaTitles.count)")
        return entities
    }

}

private enum WikipediaGetPagesError: Error {
    case invalidBaseURL(URL)
    case invalidComponents(URLComponents)
    case pageNormalized
    case noPages
    case missingPages
    case hasContinue
}

private struct WikipediaGetPagesResult: Decodable {

    let query: WikipediaGetPagesResultQuery?

    let error: WikipediaGetPagesResultError?
    let warnings: [String: [String: String]]?
    let `continue`: WikipediaGetPagesResultContinue?

}

private struct WikipediaGetPagesResultQuery: Decodable {

    let pages: [String: WikipediaAPIPage]?

    let normalized: [WikipediaGetPagesResultNormalization]?

}

private struct WikipediaGetPagesResultContinue: Decodable {

}

private struct WikipediaGetPagesResultNormalization: Decodable, Error {
    let from: String
    let to: String
}

private struct WikipediaGetPagesResultError: Decodable, Error {
    let code: String
    let info: String
}
