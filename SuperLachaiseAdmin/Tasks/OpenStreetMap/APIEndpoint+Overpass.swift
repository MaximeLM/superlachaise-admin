//
//  APIEndpoint+Overpass.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 28/11/2017.
//

import Foundation

extension APIEndpoint {

    static let overpass: APIEndpoint = {
        let baseURL = URL.with(string: "https://overpass-api.de/api/")
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = [
            "User-Agent": UserAgent.default,
        ]
        return APIEndpoint(baseURL: baseURL, configuration: configuration)
    }()

}
