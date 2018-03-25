//
//  SyncEntries.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 25/03/2018.
//

import Foundation
import RealmSwift
import RxSwift

final class SyncEntries: Task {

    enum Scope: CustomStringConvertible {

        case all
        case single(wikidataId: String)

        var description: String {
            switch self {
            case .all:
                return "all"
            case let .single(wikidataId):
                return wikidataId
            }
        }

    }

    let scope: Scope

    init(scope: Scope) {
        self.scope = scope
    }

    var description: String {
        return "\(type(of: self)) (\(scope.description))"
    }

    // MARK: Execution

    func asSingle() -> Single<Void> {
        return Single.error(Errors.notImplemented)
    }

    // MARK: Private properties

    private let realmDispatchQueue = DispatchQueue(label: "SyncEntries.realm")

}

private extension SyncEntries {

}
