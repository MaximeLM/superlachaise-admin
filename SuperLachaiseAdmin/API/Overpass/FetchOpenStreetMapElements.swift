//
//  FetchOpenStreetMapElements.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 28/11/2017.
//

import CoreLocation
import Foundation
import RxSwift

final class FetchOpenStreetMapElements: BackgroundTask {

    let scope: Scope

    init(scope: Scope) {
        self.scope = scope
    }

    // MARK: Types

    typealias BoundingBox = (minLatitude: Double, minLongitude: Double, maxLatitude: Double, maxLongitude: Double)

    enum Scope {
        case all(boundingBox: BoundingBox, tags: [String])
        case list([OpenStreetMapId])
    }

    // MARK: Execution

    override func execute(onSuccess: (() -> Void)?, onError: ((Error) -> Void)?) throws -> Disposable {
        throw Errors.notImplemented
    }

}
