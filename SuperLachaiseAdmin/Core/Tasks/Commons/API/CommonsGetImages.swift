//
//  CommonsGetImages.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 02/03/2018.
//

import Foundation
import RxSwift

final class CommonsGetImages {

    let endpoint: APIEndpointType

    let commonsIds: [String]

    // MARK: Init

    init(endpoint: APIEndpointType, commonsIds: [String]) {
        self.endpoint = endpoint
        self.commonsIds = commonsIds.uniqueValues()
    }

    // MARK: Execution

    func asSingle() -> Single<[CommonsAPIImage]> {
        return Observable.from(commonsIds.chunked(by: 20))
            .flatMap(self.chunkImages)
            .reduce([], accumulator: self.mergeImages)
            .asSingle()
    }

}

private extension CommonsGetImages {

    func chunkImages(commonsIdsChunk: [String]) throws -> Single<[CommonsAPIImage]> {
        let request = try self.chunkRequest(commonsIdsChunk: commonsIdsChunk)
        return endpoint.data(request: request)
            .map { try JSONDecoder().decode(CommonsGetImagesResult.self, from: $0) }
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
                if result.continue != nil {
                    Logger.warning("Result has continue")
                }
                guard let pagesDict = result.query?.pages else {
                    throw CommonsGetImagesError.noPages
                }
                let images = Array(pagesDict.values)
                guard images.count == commonsIdsChunk.count else {
                    throw CommonsGetImagesError.missingImages
                }
                if let normalized = result.query?.normalized {
                    normalized.forEach { normalization in
                        Logger.warning("Page normalized from \(normalization.from) to \(normalization.to)")
                    }
                }
                return images.filter { image in
                    if image.missing != nil {
                        Logger.warning("Image \(image) is missing")
                        return false
                    } else {
                        return true
                    }
                }
            }
    }

    func chunkRequest(commonsIdsChunk: [String]) throws -> URLRequest {
        guard var components = URLComponents(url: endpoint.baseURL, resolvingAgainstBaseURL: false) else {
            throw CommonsGetImagesError.invalidBaseURL(endpoint.baseURL)
        }
        let titles = commonsIdsChunk.map { "File:\($0)" }
        components.queryItems = [
            URLQueryItem(name: "action", value: "query"),
            URLQueryItem(name: "format", value: "json"),
            URLQueryItem(name: "prop", value: "imageinfo"),
            URLQueryItem(name: "iiprop", value: ["url", "size", "extmetadata"].joined(separator: "|")),
            URLQueryItem(name: "iiurlwidth", value: "42"),
            URLQueryItem(name: "iiextmetadatafilter", value: ["Artist", "LicenseShortName"].joined(separator: "|")),
            URLQueryItem(name: "titles", value: titles.joined(separator: "|")),
        ]
        guard let url = components.url else {
            throw CommonsGetImagesError.invalidComponents(components)
        }
        return URLRequest(url: url)
    }

    func mergeImages(images: [CommonsAPIImage], chunkImages: [CommonsAPIImage]) -> [CommonsAPIImage] {
        var images = images
        images.append(contentsOf: chunkImages)
        Logger.debug("\(images.count)/\(commonsIds.count)")
        return images
    }

}

private enum CommonsGetImagesError: Error {
    case invalidBaseURL(URL)
    case invalidComponents(URLComponents)
    case pageNormalized
    case noPages
    case missingImages
}

private struct CommonsGetImagesResult: Decodable {

    let query: CommonsGetImagesResultQuery?

    let error: CommonsGetImagesResultError?
    let warnings: [String: [String: String]]?
    let `continue`: CommonsGetImagesResultContinue?

}

private struct CommonsGetImagesResultQuery: Decodable {

    let pages: [String: CommonsAPIImage]?

    let normalized: [CommonsGetImagesResultNormalization]?

}

private struct CommonsGetImagesResultContinue: Decodable {

}

private struct CommonsGetImagesResultNormalization: Decodable, Error {
    let from: String
    let to: String
}

private struct CommonsGetImagesResultError: Decodable, Error {
    let code: String
    let info: String
}
