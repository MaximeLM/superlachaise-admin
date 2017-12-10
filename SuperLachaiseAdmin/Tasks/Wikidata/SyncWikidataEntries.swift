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
    let languages: [String]

    let endpoint: APIEndpointType

    init(scope: Scope, languages: [String], endpoint: APIEndpointType) {
        self.scope = scope
        self.languages = languages
        self.endpoint = endpoint
    }

    private let realmDispatchQueue = DispatchQueue(label: "SyncWikidataEntries.realm")

    // MARK: Types

    enum Scope {
        case all
        case list(wikidataIds: [String])
    }

    // MARK: Execution

    func asCompletable() -> Completable {
        return getInitialEntities().asObservable()
            .flatMap { $0.asObservable() }
            .ignoreElements()
    }

    // MARK: Requests

    func getInitialEntities() -> Single<WikidataGetEntities> {
        return Realm.async(dispatchQueue: realmDispatchQueue) { realm in
            let wikidataIds: [String]
            switch self.scope {
            case .all:
                wikidataIds = SuperLachaisePOI.list(filter: "")(realm).map { $0.wikidataId }
            case let .list(_wikidataIds):
                wikidataIds = _wikidataIds
            }
            return WikidataGetEntities(endpoint: self.endpoint,
                                       wikidataIds: wikidataIds,
                                       languages: self.languages)
        }
    }

}
