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
        return commonsFiles()
            .flatMap(self.deleteOrphans)
    }

    // MARK: Private properties

    private let realmDispatchQueue = DispatchQueue(label: "SyncCommonsFiles.realm")

}

private extension SyncCommonsFiles {

    // MARK: Commons Ids

    func commonsIds() -> Single<[String]> {
        switch self.scope {
        case .all:
            // Get Commons ids from Wikidata entries
            return Realm.async(dispatchQueue: realmDispatchQueue) { realm in
                return WikidataEntry.all()(realm).flatMap { wikidataEntry in
                    [wikidataEntry.imageCommonsId, wikidataEntry.imageOfGraveCommonsId].flatMap { $0 }
                }
            }
        case let .single(commonsId):
            return Single.just([commonsId])
        }
    }

    // MARK: Commons API images

    func commonsAPIImages(commonsIds: [String]) -> Single<[CommonsAPIImage]> {
        return CommonsGetImages(endpoint: endpoint, commonsIds: commonsIds)
            .asSingle()
    }

    // MARK: Commons files

    func commonsFiles() -> Single<[String]> {
        return commonsIds()
            .flatMap(self.commonsAPIImages)
            .flatMap(self.saveCommonsFiles)
            .do(onSuccess: { Logger.info("Fetched \($0.count) \(CommonsFile.self)(s)") })
    }

    func saveCommonsFiles(commonsAPIImages: [CommonsAPIImage]) -> Single<[String]> {
        return Realm.async(dispatchQueue: realmDispatchQueue) { realm in
            try realm.write {
                try self.saveCommonsFiles(commonsAPIImages: commonsAPIImages, realm: realm)
            }
        }
    }

    func saveCommonsFiles(commonsAPIImages: [CommonsAPIImage], realm: Realm) throws -> [String] {
        return try commonsAPIImages.map { commonsAPIImage in
            try self.commonsFile(commonsAPIImage: commonsAPIImage, realm: realm).commonsId
        }
    }

    // MARK: Commons file

    func commonsFile(commonsAPIImage: CommonsAPIImage, realm: Realm) throws -> CommonsFile {
        // Commons Id
        if !commonsAPIImage.title.hasPrefix("File:") {
            Logger.warning("Invalid \(CommonsAPIImage.self) title: \(commonsAPIImage.title)")
        }
        let commonsId = String(commonsAPIImage.title.dropFirst(5))
        let commonsFile = CommonsFile.findOrCreate(commonsId: commonsId)(realm)
        commonsFile.deleted = false

        guard let imageInfo = commonsAPIImage.imageinfo?.first else {
            throw SyncCommonsFilesError.missingImageInfo
        }

        commonsFile.rawImageURL = imageInfo.url
        commonsFile.width = Float(imageInfo.width)
        commonsFile.height = Float(imageInfo.height)
        commonsFile.thumbnailURLTemplate = try self.thumbnailURLTemplate(imageInfo: imageInfo)

        // Author
        let author = self.author(imageInfo: imageInfo)
        if author == nil {
            Logger.warning("\(CommonsFile.self) \(commonsFile) has no author")
        }
        commonsFile.author = author

        // License
        let license = self.license(imageInfo: imageInfo)
        if license == nil {
            Logger.warning("\(CommonsFile.self) \(commonsFile) has no license")
        }
        commonsFile.license = license

        return commonsFile
    }

    func thumbnailURLTemplate(imageInfo: CommonsAPIImageInfo) throws -> String {
        let components = imageInfo.thumburl.components(separatedBy: "\(imageInfo.thumbwidth)px-")
        guard components.count == 2 else {
            throw SyncCommonsFilesError.invalidThumbnailURL(imageInfo.thumburl)
        }
        return components.joined(separator: "{{width}}px-")
    }

    func author(imageInfo: CommonsAPIImageInfo) -> String? {
        guard var artist = imageInfo.extmetadata.artist?.value else {
            return nil
        }

        // Strip HTML
        if let htmlData = artist.data(using: .utf8) {
            let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
                .characterEncoding: NSNumber(value: String.Encoding.utf8.rawValue),
            ]
            if let attributedString = NSAttributedString(html: htmlData, options: options, documentAttributes: nil) {
                artist = attributedString.string
            }
        }

        // Trim
        artist = artist.trimmingCharacters(in: .whitespacesAndNewlines)
        artist = artist.trimmingCharacters(in: CharacterSet(charactersIn: "\u{FFFC}"))

        return artist
    }

    func license(imageInfo: CommonsAPIImageInfo) -> String? {
        guard let licenseShortName = imageInfo.extmetadata.licenseShortName?.value else {
            return nil
        }
        return licenseShortName
    }

    // MARK: Orphans

    func deleteOrphans(fetchedCommonsIds: [String]) -> Single<Void> {
        return Realm.async(dispatchQueue: realmDispatchQueue) { realm in
            try realm.write {
                try self.deleteOrphans(fetchedCommonsIds: fetchedCommonsIds, realm: realm)
            }
        }
    }

    func deleteOrphans(fetchedCommonsIds: [String], realm: Realm) throws {
        // List existing objects
        var orphanedObjects: Set<CommonsFile>
        switch scope {
        case .all:
            orphanedObjects = Set(CommonsFile.all()(realm))
        case .single:
            orphanedObjects = Set()
        }

        orphanedObjects = orphanedObjects.filter { !fetchedCommonsIds.contains($0.commonsId) }

        if !orphanedObjects.isEmpty {
            orphanedObjects.forEach { $0.deleted = true }
            Logger.info("Flagged \(orphanedObjects.count) \(CommonsFile.self)(s) for deletion")
        }
    }

}

enum SyncCommonsFilesError: Error {
    case missingImageInfo
    case invalidThumbnailURL(String)
}
