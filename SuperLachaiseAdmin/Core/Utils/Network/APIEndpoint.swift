//
//  APIEndpoint.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 27/11/2017.
//

import Foundation
import RxCocoa
import RxSwift

/**
 Allow mocking network
 */
protocol APIEndpointType {

    var baseURL: URL { get }

    func response(request: URLRequest) -> Single<(response: HTTPURLResponse, data: Data)>

    func data(request: URLRequest) -> Single<Data>

}

/**
 Wraps URL data tasks in an operation queue to enforce httpMaximumConnectionsPerHost and avoid timeouts
 */
final class APIEndpoint: APIEndpointType {

    let baseURL: URL

    // MARK: Init

    convenience init(baseURL: URL, configuration: URLSessionConfiguration) {
        self.init(baseURL: baseURL, session: URLSession(configuration: configuration))
    }

    init(baseURL: URL, session: URLSession) {
        self.baseURL = baseURL
        self.session = session
        self.operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = session.configuration.httpMaximumConnectionsPerHost
    }

    // MARK: Tasks

    func response(request: URLRequest) -> Single<(response: HTTPURLResponse, data: Data)> {
        return session.rx.response(request: request)
            .enqueue(in: operationQueue)
            .asSingle()
    }

    func data(request: URLRequest) -> Single<Data> {
        return session.rx.data(request: request)
            .enqueue(in: operationQueue)
            .asSingle()
    }

    // MARK: Private

    private let session: URLSession

    private let operationQueue: OperationQueue

}
