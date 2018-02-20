//
//  CommonsGetCategories.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 20/02/2018.
//

import Foundation
import RxSwift

final class CommonsGetCategories {

    let endpoint: APIEndpointType

    let commonsCategoriesIds: [String]

    // MARK: Init

    init(endpoint: APIEndpointType, commonsCategoriesIds: [String]) {
        self.endpoint = endpoint
        self.commonsCategoriesIds = commonsCategoriesIds.uniqueValues()
    }

    // MARK: Execution

    func asSingle() -> Single<[CommonsAPICategory]> {
        return Observable.from(commonsCategoriesIds.chunked(by: 20))
            .flatMap(self.chunkCategories)
            .reduce([], accumulator: self.mergeCategories)
            .asSingle()
    }

}

private extension CommonsGetCategories {

    func chunkCategories(commonsCategoriesIdsChunk: [String]) throws -> Single<[CommonsAPICategory]> {
        let request = try self.chunkRequest(commonsCategoriesIdsChunk: commonsCategoriesIdsChunk)
        return endpoint.data(request: request)
            .map { try JSONDecoder().decode(CommonsGetCategoriesResult.self, from: $0) }
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
                    throw CommonsGetCategoriesError.hasContinue
                }
                guard let pagesDict = result.query?.pages else {
                    throw CommonsGetCategoriesError.noPages
                }
                let pages = Array(pagesDict.values)
                guard pages.count == commonsCategoriesIdsChunk.count else {
                    throw CommonsGetCategoriesError.missingPages
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

    func chunkRequest(commonsCategoriesIdsChunk: [String]) throws -> URLRequest {
        guard var components = URLComponents(url: endpoint.baseURL, resolvingAgainstBaseURL: false) else {
            throw CommonsGetCategoriesError.invalidBaseURL(endpoint.baseURL)
        }
        let titles = commonsCategoriesIdsChunk.map { "Category:\($0)" }.joined(separator: "|")
        components.queryItems = [
            URLQueryItem(name: "action", value: "query"),
            URLQueryItem(name: "format", value: "json"),
            URLQueryItem(name: "prop", value: "revisions"),
            URLQueryItem(name: "rvprop", value: "content"),
            URLQueryItem(name: "titles", value: titles),
        ]
        guard let url = components.url else {
            throw CommonsGetCategoriesError.invalidComponents(components)
        }
        return URLRequest(url: url)
    }

    func mergeCategories(categories: [CommonsAPICategory],
                         chunkCategories: [CommonsAPICategory]) -> [CommonsAPICategory] {
        var categories = categories
        categories.append(contentsOf: chunkCategories)
        Logger.debug("\(categories.count)/\(commonsCategoriesIds.count)")
        return categories
    }

}

private enum CommonsGetCategoriesError: Error {
    case invalidBaseURL(URL)
    case invalidComponents(URLComponents)
    case pageNormalized
    case noPages
    case missingPages
    case hasContinue
}

private struct CommonsGetCategoriesResult: Decodable {

    let query: CommonsGetCategoriesResultQuery?

    let error: CommonsGetCategoriesResultError?
    let warnings: [String: [String: String]]?
    let `continue`: CommonsGetCategoriesResultContinue?

}

private struct CommonsGetCategoriesResultQuery: Decodable {

    let pages: [String: CommonsAPICategory]?

    let normalized: [CommonsGetCategoriesResultNormalization]?

}

private struct CommonsGetCategoriesResultContinue: Decodable {

}

private struct CommonsGetCategoriesResultNormalization: Decodable, Error {
    let from: String
    let to: String
}

private struct CommonsGetCategoriesResultError: Decodable, Error {
    let code: String
    let info: String
}
