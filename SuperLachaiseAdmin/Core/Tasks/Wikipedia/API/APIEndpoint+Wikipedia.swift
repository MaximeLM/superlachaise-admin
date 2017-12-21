//
//  APIEndpoint+Wikipedia.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 21/12/2017.
//

import Foundation

extension APIEndpoint {

    private static var wikipediaEndpoints: [String: APIEndpoint] = [:]

    static func wikipedia(language: String) -> APIEndpoint {
        if let endpoint = wikipediaEndpoints[language] {
            return endpoint
        } else {
            guard let baseURL = URL(string: "https://\(language).wikipedia.org/w/api.php") else {
                fatalError("Invalid base URL")
            }
            let configuration = URLSessionConfiguration.default
            configuration.httpAdditionalHeaders = [
                "User-Agent": UserAgent.default,
            ]
            let endpoint = APIEndpoint(baseURL: baseURL, configuration: configuration)
            wikipediaEndpoints[language] = endpoint
            return endpoint
        }
    }

}
