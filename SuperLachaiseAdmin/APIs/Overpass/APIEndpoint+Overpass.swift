//
//  APIEndpoint+Overpass.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 28/11/2017.
//

import Foundation

extension APIEndpoint {

    static let overpass: APIEndpoint = {
        guard let baseURL = URL(string: "https://overpass-api.de/api") else {
            fatalError("Invalid base URL")
        }
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = [
            "User-Agent": UserAgent.default,
        ]
        return APIEndpoint(baseURL: baseURL, configuration: configuration)
    }()

}
