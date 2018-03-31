//
//  ExportToJSON.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 31/03/2018.
//

import Foundation
import RealmSwift
import RxSwift

final class ExportToJSON: Task {

    let directoryURL: URL

    init(directoryURL: URL) {
        self.directoryURL = directoryURL
    }

    var description: String {
        return "\(type(of: self)) (\(directoryURL.path))"
    }

    // MARK: Execution

    func asSingle() -> Single<Void> {
        return Single.error(Errors.notImplemented)
    }

    // MARK: Private properties

    private let realmDispatchQueue = DispatchQueue(label: "ExportToJSON.realm")

}
