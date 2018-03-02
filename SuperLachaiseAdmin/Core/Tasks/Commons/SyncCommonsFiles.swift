//
//  SyncCommonsFiles.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 02/03/2018.
//

import Foundation
import RealmSwift
import RxSwift

final class SyncCommonsFiles: Task {

    enum Scope: CustomStringConvertible {

        case all
        case single(commonsId: String)

        var description: String {
            switch self {
            case .all:
                return "all"
            case let .single(commonsId):
                return commonsId
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

    // MARK: Private properties

    private let realmDispatchQueue = DispatchQueue(label: "SyncCommonsFiles.realm")

}
