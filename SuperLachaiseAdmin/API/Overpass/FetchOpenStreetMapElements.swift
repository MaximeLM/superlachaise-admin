//
//  FetchOpenStreetMapElements.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 28/11/2017.
//

import CoreLocation
import Foundation
import RxSwift

final class FetchOpenStreetMapElements: AsyncTask {

    private let scope: Scope
    private let endpoint: APIEndpointType

    init(scope: Scope, endpoint: APIEndpointType = APIEndpoint.overpass) {
        self.scope = scope
        self.endpoint = endpoint
    }

    // MARK: Types

    typealias BoundingBox = (minLatitude: Double, minLongitude: Double, maxLatitude: Double, maxLongitude: Double)

    enum Scope {
        case all(boundingBox: BoundingBox, tags: [String])
        case list([OpenStreetMapId])
    }

    // MARK: Execution

    func execute(onCompleted: (() -> Void), onError: ((Error) -> Void)) throws -> Disposable {
        throw Errors.notImplemented
    }

}
