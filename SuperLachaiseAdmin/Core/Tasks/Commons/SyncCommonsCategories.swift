//
//  SyncCommonsCategories.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 20/02/2018.
//

import Foundation
import RealmSwift
import RxSwift

final class SyncCommonsCategories: Task {

    enum Scope: CustomStringConvertible {

        case all
        case single(name: String)

        var description: String {
            switch self {
            case .all:
                return "all"
            case let .single(name):
                return name
            }
        }

    }

    let scope: Scope

    let endpoint: APIEndpointType

    init(scope: Scope, endpoint: APIEndpointType) {
        self.scope = scope
        self.endpoint = endpoint
    }

    var description: String {
        return "\(type(of: self)) (\(scope.description))"
    }

    // MARK: Execution

    func asSingle() -> Single<Void> {
        return Single.error(Errors.notImplemented)
    }

}
