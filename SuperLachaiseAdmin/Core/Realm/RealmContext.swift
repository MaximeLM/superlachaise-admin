//
//  RealmContext.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 26/11/2017.
//

import Foundation
import RealmSwift
import RxSwift

final class RealmContext {

    // MARK: Properties

    let configuration: Realm.Configuration

    var viewRealm: Realm {
        assertIsMainThread()
        return _viewRealm
    }

    var viewRealmSaveNotification: Observable<Void> {
        return Observable<(Realm, Realm.Notification)>.from(realm: viewRealm)
            .map { _ in }
            .catchErrorJustReturn(())
    }

    let databaseDirectoryURL: URL
    let databaseFileURL: URL

    // MARK: Utils

    func deleteFlaggedObjects(realm: Realm) throws {
        try realm.write {
            deleteFlaggedObjects(type: SuperLachaisePOI.self, realm: realm)
            deleteFlaggedObjects(type: OpenStreetMapElement.self, realm: realm)
            deleteFlaggedObjects(type: WikidataEntry.self, realm: realm)
            deleteFlaggedObjects(type: WikipediaPage.self, realm: realm)
            deleteFlaggedObjects(type: CommonsFile.self, realm: realm)
        }
    }

    // MARK: Init

    convenience init(databaseDirectoryName: String, databaseFileName: String) throws {
        let documentsDirectoryURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        let databaseDirectoryURL = documentsDirectoryURL
            .appendingPathComponent(Bundle.main.bundleIdentifier ?? "SuperLachaise", isDirectory: true)
            .appendingPathComponent(databaseDirectoryName, isDirectory: true)
        try self.init(databaseDirectoryURL: databaseDirectoryURL, databaseFileName: databaseFileName)
    }

    init(databaseDirectoryURL: URL, databaseFileName: String) throws {
        assertIsMainThread()

        self.databaseDirectoryURL = databaseDirectoryURL
        self.databaseFileURL = databaseDirectoryURL
            .appendingPathComponent("\(databaseFileName).realm", isDirectory: false)
        self.configuration = Realm.Configuration(
            fileURL: databaseFileURL,
            schemaVersion: 0,
            deleteRealmIfMigrationNeeded: true,
            shouldCompactOnLaunch: RealmContext.shouldCompactOnLaunch)

        // Create database directory if needed
        let fileManager = FileManager.default
        let databaseDirectoryURL = databaseFileURL.deletingLastPathComponent()
        if !fileManager.fileExists(atPath: databaseDirectoryURL.path) {
            try fileManager.createDirectory(at: databaseDirectoryURL,
                                            withIntermediateDirectories: true,
                                            attributes: nil)
        }

        // Keep a Realm opened
        self._viewRealm = try Realm(configuration: configuration)

        try deleteFlaggedObjects(realm: _viewRealm)

        Logger.info("database initialized at \(databaseFileURL.path)")
    }

    // MARK: Private

    private let _viewRealm: Realm

    private static func shouldCompactOnLaunch(totalBytes: Int, usedBytes: Int) -> Bool {
        // totalBytes refers to the size of the file on disk in bytes (data + free space)
        // usedBytes refers to the number of bytes used by data in the file
        // Compact if the file is over 100MB in size and less than 50% 'used'
        let totalBytesInMB = Double(totalBytes) / (1024 * 1024)
        let usedRatio = Double(usedBytes) / Double(totalBytes)
        let shouldCompact = (totalBytesInMB > 100) && usedRatio < 0.5
        Logger.info(String(format: "shouldCompactOnLaunch: %.2f%% of %.2fMB => %@",
                           usedRatio * 100,
                           totalBytesInMB,
                           "\(shouldCompact)"))
        return shouldCompact
    }

    private func deleteFlaggedObjects<Element: Object & Deletable>(type: Element.Type, realm: Realm) {
        let objects = Array(realm.objects(type).filter("deleted == true"))
        if !objects.isEmpty {
            objects.forEach { $0.delete() }
            Logger.info("Deleted \(objects.count) \(type)(s)")
        }
    }

}
