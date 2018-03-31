//
//  ExportToRealm.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 31/03/2018.
//

import Foundation
import RealmSwift
import RxSwift

final class ExportToRealm: Task {

    let fileURL: URL

    init(fileURL: URL) {
        self.fileURL = fileURL
    }

    var description: String {
        return "\(type(of: self)) (\(fileURL.path))"
    }

    // MARK: Execution

    func asSingle() -> Single<Void> {
        return Single.error(Errors.notImplemented)
    }

    // MARK: Private properties

    private let realmDispatchQueue = DispatchQueue(label: "ExportToRealm.realm")

}
