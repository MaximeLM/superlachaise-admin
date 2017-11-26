//
//  URLSessionQueue.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 26/11/2017.
//

import Foundation
import RxCocoa
import RxSwift

/**
 Wraps URL data tasks in an operation queue to enforce httpMaximumConnectionsPerHost and avoid timeouts
 */
class URLSessionQueue {

    // MARK: Init

    convenience init(configuration: URLSessionConfiguration = URLSessionConfiguration.default) {
        self.init(session: URLSession(configuration: configuration))
    }

    init(session: URLSession) {
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
