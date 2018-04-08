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
        return Realm.async(dispatchQueue: realmDispatchQueue) { realm in
            try self.exportToRealm(sourceRealm: realm)
        }
    }

    // MARK: Private properties

    private let realmDispatchQueue = DispatchQueue(label: "ExportToRealm.realm")

}

private extension ExportToRealm {

    func exportToRealm(sourceRealm: Realm) throws {
        let destRealm = try self.destRealm(sourceRealm: sourceRealm)
        if FileManager.default.fileExists(atPath: fileURL.path) {
            try FileManager.default.removeItem(at: fileURL)
        }
        try destRealm.writeCopy(toFile: fileURL)
    }

    func destRealm(sourceRealm: Realm) throws -> Realm {
        let destRealm = try Realm(configuration: Realm.Configuration(inMemoryIdentifier: "export", objectTypes: [
            PointOfInterest.self,
            Entry.self,
            LocalizedEntry.self,
            Category.self,
            LocalizedCategory.self,
            CommonsFile.self,
            DatabaseV1Mapping.self,
        ]))
        try destRealm.write {
            try copyObjects(PointOfInterest.self, sourceRealm: sourceRealm, destRealm: destRealm)
            try copyObjects(DatabaseV1Mapping.self, sourceRealm: sourceRealm, destRealm: destRealm)

            sourceRealm.objects(LocalizedEntry.self).forEach {
                let localization = destRealm.create(LocalizedEntry.self, value: [
                    "language": $0.language,
                    "name": $0.name,
                    "summary": $0.summary,
                    "defaultSort": $0.defaultSort,
                    "wikipediaTitle": $0.wikipediaTitle,
                    "wikipediaExtract": $0.wikipediaExtract,
                ], update: false)
                if let wikidataId = $0.entry?.wikidataId {
                    localization.entry = destRealm.object(ofType: Entry.self, forPrimaryKey: wikidataId)
                }
            }

            sourceRealm.objects(LocalizedCategory.self).forEach {
                let localization = destRealm.create(LocalizedCategory.self, value: [
                    "language": $0.language,
                    "name": $0.name,
                ], update: false)
                if let id = $0.category?.id {
                    localization.category = destRealm.object(ofType: Category.self, forPrimaryKey: id)
                }
            }
        }
        return destRealm
    }

    func copyObjects<O: Object>(_ type: O.Type, sourceRealm: Realm, destRealm: Realm) throws {
        sourceRealm.objects(O.self).forEach {
            destRealm.create(O.self, value: $0, update: true)
        }
    }

}
