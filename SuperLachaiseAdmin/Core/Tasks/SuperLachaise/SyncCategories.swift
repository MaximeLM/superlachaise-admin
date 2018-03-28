//
//  SyncCategories.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 28/03/2018.
//

import Foundation

import Foundation
import RealmSwift
import RxSwift

final class SyncCategories: Task {

    enum Scope: CustomStringConvertible {

        case all
        case single(id: String)

        var description: String {
            switch self {
            case .all:
                return "all"
            case let .single(id):
                return id
            }
        }

    }

    let scope: Scope
    let config: SuperLachaiseConfig

    init(scope: Scope, config: SuperLachaiseConfig) {
        self.scope = scope
        self.config = config
    }

    var description: String {
        return "\(type(of: self)) (\(scope.description))"
    }

    // MARK: Execution

    func asSingle() -> Single<Void> {
        return Single.error(Errors.notImplemented)
    }

    // MARK: Private properties

    private let realmDispatchQueue = DispatchQueue(label: "SyncCategories.realm")

}

private extension SyncCategories {

}
