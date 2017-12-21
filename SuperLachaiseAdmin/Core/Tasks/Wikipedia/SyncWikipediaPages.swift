//
//  SyncWikipediaPages.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 21/12/2017.
//

import Foundation
import RealmSwift
import RxSwift

final class SyncWikipediaPages: Task {

    enum Scope {
        case all
        case single(wikipediaId: WikipediaId)
    }

    let scope: Scope

    let endpoint: (String) -> APIEndpointType

    init(scope: Scope, endpoint: @escaping (String) -> APIEndpointType) {
        self.scope = scope
        self.endpoint = endpoint
    }

    private let realmDispatchQueue = DispatchQueue(label: "SyncWikipediaPages.realm")

    // MARK: Execution

    func asSingle() -> Single<Void> {
        return Single.error(Errors.notImplemented)
    }

}
