//
//  APIEndpoint+Wikidata.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 10/12/2017.
//

import Foundation

extension APIEndpoint {

    static let wikidata: APIEndpoint = {
        guard let baseURL = URL(string: "https://www.wikidata.org/w/api.php") else {
            fatalError("Invalid base URL")
        }
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = [
            "User-Agent": UserAgent.default,
        ]
        return APIEndpoint(baseURL: baseURL, configuration: configuration)
    }()

}
