//
//  SyncCommonsFiles.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 02/03/2018.
//

import CoreData
import Foundation
import RxSwift

final class SyncCommonsFiles: Task {

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
    let endpoint: APIEndpointType
    let performInBackground: Single<NSManagedObjectContext>

    init(scope: Scope, endpoint: APIEndpointType, performInBackground: Single<NSManagedObjectContext>) {
        self.scope = scope
        self.endpoint = endpoint
        self.performInBackground = performInBackground
    }

    var description: String {
        return "\(type(of: self)) (\(scope.description))"
    }

    // MARK: Execution

    func asSingle() -> Single<Void> {
        return commonsFiles()
            .flatMap(self.deleteOrphans)
    }

}

private extension SyncCommonsFiles {

    // MARK: Commons Ids

    func commonsIds() -> Single<[String]> {
        switch self.scope {
        case .all:
            // Get Commons ids from Wikidata entries
            return performInBackground.map { context in
                context.objects(CoreDataWikidataEntry.self).fetch().flatMap { wikidataEntry in
                    [wikidataEntry.image?.id, wikidataEntry.imageOfGrave?.id].compactMap { $0 }
                }
            }
        case let .single(id):
            return Single.just([id])
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
            .do(onSuccess: { Logger.info("Fetched \($0.count) \(CoreDataCommonsFile.self)(s)") })
    }

    func saveCommonsFiles(commonsAPIImages: [CommonsAPIImage]) -> Single<[String]> {
        return performInBackground.map { context in
            try context.write {
                try self.saveCommonsFiles(commonsAPIImages: commonsAPIImages, context: context)
            }
        }
    }

    func saveCommonsFiles(commonsAPIImages: [CommonsAPIImage], context: NSManagedObjectContext) throws -> [String] {
        return try commonsAPIImages.map { commonsAPIImage in
            try self.commonsFile(commonsAPIImage: commonsAPIImage, context: context).id
        }
    }

    // MARK: Commons file

    func commonsFile(commonsAPIImage: CommonsAPIImage, context: NSManagedObjectContext) throws -> CoreDataCommonsFile {
        // Commons Id
        if !commonsAPIImage.title.hasPrefix("File:") {
            Logger.warning("Invalid \(CommonsAPIImage.self) title: \(commonsAPIImage.title)")
        }
        let commonsId = String(commonsAPIImage.title.dropFirst(5))
        let commonsFile = context.findOrCreate(CoreDataCommonsFile.self, key: commonsId)

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
            Logger.warning("\(CoreDataCommonsFile.self) \(commonsFile) has no author")
        }
        commonsFile.author = author

        // License
        let license = self.license(imageInfo: imageInfo)
        if license == nil {
            Logger.warning("\(CoreDataCommonsFile.self) \(commonsFile) has no license")
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
        guard var author = imageInfo.extmetadata.artist?.value else {
            return nil
        }

        // Strip HTML
        if let htmlData = author.data(using: .utf8) {
            let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
                .characterEncoding: NSNumber(value: String.Encoding.utf8.rawValue),
            ]
            if let attributedString = NSAttributedString(html: htmlData, options: options, documentAttributes: nil) {
                author = attributedString.string
            }
        }

        // Cleanup, put on one line
        author = author
            .split(separator: "\n")
            .compactMap {
                let trimmedLine = $0
                    .replacingOccurrences(of: " (talk)", with: "")
                    .replacingOccurrences(of: "User:", with: "")
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                    .trimmingCharacters(in: CharacterSet(charactersIn: "\u{FFFC}•\t"))
                if trimmedLine == "Attribution" || trimmedLine.hasPrefix("(required by the license)") {
                    return nil
                }
                return trimmedLine
            }
            .joined(separator: " - ")

        return author
    }

    func license(imageInfo: CommonsAPIImageInfo) -> String? {
        guard let licenseShortName = imageInfo.extmetadata.licenseShortName?.value else {
            return nil
        }
        return licenseShortName
    }

    // MARK: Orphans

    func deleteOrphans(fetchedIds: [String]) -> Single<Void> {
        return performInBackground.map { context in
            try context.write {
                try self.deleteOrphans(fetchedIds: fetchedIds, context: context)
            }
        }
    }

    func deleteOrphans(fetchedIds: [String], context: NSManagedObjectContext) throws {
        // List existing objects
        var orphanedObjects: Set<CoreDataCommonsFile>
        switch scope {
        case .all:
            orphanedObjects = Set(context.objects(CoreDataCommonsFile.self).fetch())
        case .single:
            orphanedObjects = Set()
        }

        orphanedObjects = orphanedObjects.filter { !fetchedIds.contains($0.id) }

        if !orphanedObjects.isEmpty {
            Logger.info("Deleting \(orphanedObjects.count) \(CoreDataCommonsFile.self)(s)")
            orphanedObjects.forEach { context.delete($0) }
        }
    }

}

enum SyncCommonsFilesError: Error {
    case missingImageInfo
    case invalidThumbnailURL(String)
}
