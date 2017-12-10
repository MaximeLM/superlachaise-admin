//
//  SyncWikidataEntries.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 10/12/2017.
//

import Foundation
import RealmSwift
import RxSwift

final class SyncWikidataEntries: Task {

    let scope: Scope

    let endpoint: APIEndpointType

    init(scope: Scope, endpoint: APIEndpointType) {
        self.scope = scope
        self.endpoint = endpoint
    }

    // MARK: Types

    enum Scope {
        case all
        case list(wikidataIds: [String])
    }

    // MARK: Execution

    func asCompletable() -> Completable {
        return Completable.error(Errors.notImplemented)
    }

}
