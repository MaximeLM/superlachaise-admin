//
//  APIEndpoint+Commons.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 20/02/2018.
//

import Foundation

extension APIEndpoint {

    static let commons: APIEndpoint = {
        guard let baseURL = URL(string: "https://commons.wikimedia.org/w/api.php") else {
            fatalError("Invalid base URL")
        }
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = [
            "User-Agent": UserAgent.default,
        ]
        return APIEndpoint(baseURL: baseURL, configuration: configuration)
    }()

}
