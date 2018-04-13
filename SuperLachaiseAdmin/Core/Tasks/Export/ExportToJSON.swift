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
    let config: ExportConfig

    init(directoryURL: URL, config: ExportConfig) {
        self.directoryURL = directoryURL
        self.config = config
    }

    var description: String {
        return "\(type(of: self)) (\(directoryURL.path))"
    }

    // MARK: Execution

    func asSingle() -> Single<Void> {
        return Realm.async(dispatchQueue: realmDispatchQueue) { realm in
            try self.exportToJSON(realm: realm)
        }
    }

    // MARK: Private properties

    private let realmDispatchQueue = DispatchQueue(label: "ExportToJSON.realm")

    private lazy var jsonEncoder: JSONEncoder = {
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return jsonEncoder
    }()

}

private extension ExportToJSON {

    func exportToJSON(realm: Realm) throws {
        let pointsOfInterest = try exportPointsOfInterest(realm: realm)
        _ = try exportOpenStreetMapElements(pointsOfInterest: pointsOfInterest, realm: realm)
        let entries = try exportEntries(pointsOfInterest: pointsOfInterest, realm: realm)
        _ = try exportWikipediaPages(entries: entries, realm: realm)
        _ = try exportCategories(entries: entries, realm: realm)
        _ = try exportCommonsFiles(pointsOfInterest: pointsOfInterest, entries: entries, realm: realm)
    }

    // MARK: Export objects

    func exportPointsOfInterest(realm: Realm) throws -> [PointOfInterest] {
        let pointsOfInterest = Array(PointOfInterest.all()(realm)).sorted { $0.id < $1.id }
        try writeObjects(pointsOfInterest, name: "points_of_interest")
        return pointsOfInterest
    }

    func exportOpenStreetMapElements(pointsOfInterest: [PointOfInterest],
                                     realm: Realm) throws -> [OpenStreetMapElement] {
        let openStreetMapElements = pointsOfInterest
            .compactMap { $0.openStreetMapElement }
            .uniqueValues()
            .sorted { $0.id < $1.id }
        try writeObjects(openStreetMapElements, name: "openstreetmap_elements")
        return openStreetMapElements
    }

    func exportEntries(pointsOfInterest: [PointOfInterest], realm: Realm) throws -> [Entry] {
        let entries = pointsOfInterest
            .flatMap { pointOfInterest -> [Entry] in
                var entries = [pointOfInterest.mainEntry].compactMap { $0 }
                entries.append(contentsOf: Array(pointOfInterest.secondaryEntries))
                return entries
            }
            .uniqueValues()
            .sorted { $0.id < $1.id }
        try writeObjects(entries, name: "entries")
        return entries
    }

    func exportWikipediaPages(entries: [Entry], realm: Realm) throws -> [WikipediaPage] {
        let wikipediaPages = entries
            .flatMap { entry -> [WikipediaPage] in
                entry.localizations.compactMap { $0.wikipediaPage }
            }
            .uniqueValues()
            .sorted { $0.id < $1.id }
        try writeObjects(wikipediaPages, name: "wikipedia_pages")
        return wikipediaPages
    }

    func exportCategories(entries: [Entry], realm: Realm) throws -> [Category] {
        let categories = entries
            .flatMap { entry -> [Category] in
                Array(entry.categories)
            }
            .uniqueValues()
            .sorted { $0.id < $1.id }
        try writeObjects(categories, name: "categories")
        return categories
    }

    func exportCommonsFiles(pointsOfInterest: [PointOfInterest],
                            entries: [Entry],
                            realm: Realm) throws -> [CommonsFile] {
        var commonsFiles = pointsOfInterest.compactMap { $0.image }
        commonsFiles.append(contentsOf: entries.compactMap { $0.image })
        commonsFiles = commonsFiles
            .uniqueValues()
            .sorted { $0.id < $1.id }
        try writeObjects(commonsFiles, name: "commons_files")
        return commonsFiles
    }

    // MARK: Write files

    func writeObjects<O: Encodable>(_ objects: [O], name: String) throws {
        let about: [String: String] = [
            "license": config.license,
            "source": config.source,
            "generated_by": UserAgent.default,
        ]
        let export = Export(about: about, data: objects)
        let data = try jsonEncoder.encode(export)
        try write(data: data, filename: "\(name).json")
    }

    func write(data: Data, filename: String) throws {
        let fileManager = FileManager.default

        let fileURL = directoryURL.appendingPathComponent(filename, isDirectory: false)
        if fileManager.fileExists(atPath: fileURL.path) {
            try fileManager.removeItem(at: fileURL)
        }
        try data.write(to: fileURL)
    }

}

struct Export<O: Encodable>: Encodable {

    let about: [String: String]
    let data: [O]

}

extension Category: Encodable {

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)

        let localizations = Dictionary(uniqueKeysWithValues: self.localizations
            .map { localization -> (String, LocalizedCategory) in
                (localization.language, localization)
            })
        try container.encode(localizations, forKey: .localizations)
    }

    enum CodingKeys: String, CodingKey {
        case id, localizations
    }

}

extension CommonsFile: Encodable {

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(width, forKey: .width)
        try container.encode(height, forKey: .height)
        try container.encode(imageURL?.absoluteString, forKey: .imageURL)
        try container.encode(thumbnailURLTemplate, forKey: .thumbnailURLTemplate)
        try container.encode(author, forKey: .author)
        try container.encode(license, forKey: .license)
    }

    enum CodingKeys: String, CodingKey {
        case id
        case width, height
        case imageURL = "image_url", thumbnailURLTemplate = "thumbnail_url_template"
        case author, license
    }

}

extension Entry: Encodable {

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(kind?.rawValue, forKey: .kind)
        try container.encode(dateOfBirth, forKey: .dateOfBirth)
        try container.encode(dateOfDeath, forKey: .dateOfDeath)

        try container.encode(categories.map { $0.id }, forKey: .categories)
        try container.encode(image?.id, forKey: .image)

        let localizations = Dictionary(uniqueKeysWithValues: self.localizations
            .map { localization -> (String, LocalizedEntry) in
                (localization.language, localization)
            })
        try container.encode(localizations, forKey: .localizations)
    }

    enum CodingKeys: String, CodingKey {
        case id
        case kind
        case dateOfBirth = "date_of_birth", dateOfDeath = "date_of_death"
        case categories, image, localizations
    }

}

extension LocalizedCategory: Encodable {

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(language, forKey: .language)
        try container.encode(name, forKey: .name)
    }

    enum CodingKeys: String, CodingKey {
        case language, name
    }

}

extension LocalizedEntry: Encodable {

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(language, forKey: .language)
        try container.encode(name, forKey: .name)
        try container.encode(summary, forKey: .description)
        try container.encode(defaultSort, forKey: .defaultSort)
        try container.encode(wikipediaPage?.id, forKey: .wikipediaPage)
    }

    enum CodingKeys: String, CodingKey {
        case language, name, description, defaultSort = "default_sort"
        case wikipediaPage = "wikipedia_page"
    }

}

extension OpenStreetMapElement: Encodable {

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(openStreetMapId?.elementType, forKey: .elementType)
        try container.encode(openStreetMapId?.numericId, forKey: .numericId)
        try container.encode(name, forKey: .name)

        let decimalNumberHandler = NSDecimalNumberHandler(
            roundingMode: .plain, scale: 7, raiseOnExactness: false,
            raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: false)
        let latitude = NSDecimalNumber(value: self.latitude).rounding(accordingToBehavior: decimalNumberHandler)
        let longitude = NSDecimalNumber(value: self.longitude).rounding(accordingToBehavior: decimalNumberHandler)

        try container.encode(latitude.decimalValue, forKey: .latitude)
        try container.encode(longitude.decimalValue, forKey: .longitude)
    }

    enum CodingKeys: String, CodingKey {
        case id, elementType = "element_type", numericId = "numeric_id", latitude, longitude, name
    }

}

extension OpenStreetMapElementType: Encodable {

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }

}

extension PointOfInterest: Encodable {

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)

        try container.encode(openStreetMapElement?.id, forKey: .openstreetmapElement)
        try container.encode(mainEntry?.id, forKey: .mainEntry)
        try container.encode(secondaryEntries.map { $0.id },
                             forKey: .secondaryEntries)
        try container.encode(image?.id, forKey: .image)
    }

    enum CodingKeys: String, CodingKey {
        case id, name
        case latitude, longitude
        case openstreetmapElement = "openstreetmap_element"
        case mainEntry = "main_entry", secondaryEntries = "secondary_entries"
        case image
    }

}

extension WikidataEntryDate: Encodable {

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(ISO8601DateFormatter().string(from: date), forKey: .date)
        try container.encode(precision.rawValue, forKey: .precision)
    }

    enum CodingKeys: String, CodingKey {
        case date, precision
    }

}

extension WikipediaPage: Encodable {

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(wikipediaId?.language, forKey: .language)
        try container.encode(wikipediaId?.title, forKey: .title)
        try container.encode(extract, forKey: .extract)
    }

    enum CodingKeys: String, CodingKey {
        case id, language, title
        case extract
    }

}
