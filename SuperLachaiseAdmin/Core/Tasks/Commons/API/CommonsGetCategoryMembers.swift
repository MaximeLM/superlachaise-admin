//
//  CommonsGetCategoryMembers.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 21/02/2018.
//

import Foundation
import RxSwift

final class CommonsGetCategoryMembers {

    let endpoint: APIEndpointType

    let commonsCategoriesIds: [String]

    // MARK: Init

    init(endpoint: APIEndpointType, commonsCategoriesIds: [String]) {
        self.endpoint = endpoint
        self.commonsCategoriesIds = commonsCategoriesIds.uniqueValues()
    }

    // MARK: Execution

    func asSingle() -> Single<[String: [CommonsAPICategoryMember]]> {
        return Observable.from(commonsCategoriesIds)
            .flatMap(self.singleCategoryMembers)
            .reduce([:], accumulator: self.mergeCategoryMembers)
            .asSingle()
    }

}

private extension CommonsGetCategoryMembers {

    func singleCategoryMembers(commonsCategoryId: String) throws -> Single<SingleCategoryMembers> {
        let request = try self.chunkRequest(commonsCategoryId: commonsCategoryId)
        return endpoint.data(request: request)
            .map { try JSONDecoder().decode(CommonsGetCategoryMembersResult.self, from: $0) }
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
                guard let query = result.query else {
                    throw CommonsGetCategoryMembersError.noQuery
                }
                return (commonsCategoryId, query.categorymembers)
            }
    }

    func chunkRequest(commonsCategoryId: String) throws -> URLRequest {
        guard var components = URLComponents(url: endpoint.baseURL, resolvingAgainstBaseURL: false) else {
            throw CommonsGetCategoryMembersError.invalidBaseURL(endpoint.baseURL)
        }
        components.queryItems = [
            URLQueryItem(name: "action", value: "query"),
            URLQueryItem(name: "format", value: "json"),
            URLQueryItem(name: "list", value: "categorymembers"),
            URLQueryItem(name: "cmtitle", value: "Category:\(commonsCategoryId)"),
            URLQueryItem(name: "cmtype", value: "file"),
        ]
        guard let url = components.url else {
            throw CommonsGetCategoryMembersError.invalidComponents(components)
        }
        return URLRequest(url: url)
    }

    func mergeCategoryMembers(categoryMembers: [String: [CommonsAPICategoryMember]],
                              singleCategoryMembers: SingleCategoryMembers)
        -> [String: [CommonsAPICategoryMember]] {
            var categoryMembers = categoryMembers
            categoryMembers[singleCategoryMembers.commonsCategoryId] = singleCategoryMembers.categoryMembers
            let categoryMembersCount = categoryMembers.count
            if categoryMembersCount % 20 == 0 || categoryMembersCount == commonsCategoriesIds.count {
                Logger.debug("\(categoryMembersCount)/\(commonsCategoriesIds.count)")
            }
            return categoryMembers
    }

}

private typealias SingleCategoryMembers = (commonsCategoryId: String, categoryMembers: [CommonsAPICategoryMember])

private enum CommonsGetCategoryMembersError: Error {
    case invalidBaseURL(URL)
    case invalidComponents(URLComponents)
    case noQuery
}

private struct CommonsGetCategoryMembersResult: Decodable {

    let query: CommonsGetCategoryMembersResultQuery?

    let error: CommonsGetCategoryMembersResultError?
    let warnings: [String: [String: String]]?

}

private struct CommonsGetCategoryMembersResultQuery: Decodable {

    let categorymembers: [CommonsAPICategoryMember]

}

private struct CommonsGetCategoryMembersResultError: Decodable, Error {
    let code: String
    let info: String
}
