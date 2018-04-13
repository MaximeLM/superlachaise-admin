//
//  SyncSuperLachaiseObjects.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 24/03/2018.
//

import Foundation
import RealmSwift
import RxSwift

final class SyncSuperLachaiseObjects: Task {

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

    init(scope: Scope) {
        self.scope = scope
    }

    var description: String {
        return "\(type(of: self)) (\(scope.description))"
    }

    // MARK: Execution

    func asSingle() -> Single<Void> {
        return Realm.async(dispatchQueue: realmDispatchQueue) { realm in
            try realm.write {
                let pointsOfInterest = self.syncPointsOfInterest(realm: realm)
                try self.deleteOrphans(fetchedPointOfInterestIds: pointsOfInterest.map { $0.id }, realm: realm)
            }
        }
    }

    // MARK: Private properties

    private let realmDispatchQueue = DispatchQueue(label: "SyncSuperLachaiseObjects.realm")

}

private extension SyncSuperLachaiseObjects {

    func syncPointsOfInterest(realm: Realm) -> [PointOfInterest] {
        let pointsOfInterest = openStreetMapElements(realm: realm)
            .compactMap { openStreetMapElement -> PointOfInterest? in
                guard let wikidataEntry = openStreetMapElement.wikidataEntry else {
                    Logger.warning(
                        "\(OpenStreetMapElement.self) \(openStreetMapElement) has no wikidata entry; skipping")
                    return nil
                }
                return pointOfInterest(openStreetMapElement: openStreetMapElement,
                                       wikidataEntry: wikidataEntry,
                                       realm: realm)
            }

        let crossReference = Dictionary(grouping: pointsOfInterest, by: { $0 })
        let duplicates = crossReference.filter { $0.value.count > 1 }
        for duplicate in duplicates {
            Logger.warning("""
                \(PointOfInterest.self) \(duplicate.key) is referenced by multiple OpenStreetMap elements; \
                skipping
                """)
        }
        return pointsOfInterest.filter({ !duplicates.keys.contains($0) })
    }

    func openStreetMapElements(realm: Realm) -> [OpenStreetMapElement] {
        switch self.scope {
        case .all:
            return Array(OpenStreetMapElement.all()(realm))
        case let .single(id):
            return Array(realm.objects(OpenStreetMapElement.self)
                .filter("wikidataEntry.id == %@", id))
        }
    }

    func pointOfInterest(openStreetMapElement: OpenStreetMapElement,
                         wikidataEntry: WikidataEntry,
                         realm: Realm) -> PointOfInterest? {
        guard let kind = wikidataEntry.kind else {
            Logger.warning("\(WikidataEntry.self) \(wikidataEntry) for main entry has no kind; skipping")
            return nil
        }
        guard let image = (kind == .person) ? wikidataEntry.imageOfGrave : wikidataEntry.image else {
            Logger.warning("\(WikidataEntry.self) \(wikidataEntry) for main entry has no image; skipping")
            return nil
        }

        let isMainEntryInteresting = wikidataEntry.isInteresting()
        let interestingSecondaryEntries = Array(wikidataEntry.secondaryWikidataEntries.filter { $0.isInteresting() })

        let mainWikidataEntry: WikidataEntry
        let secondaryWikidataEntries: [WikidataEntry]
        if kind == .grave && !isMainEntryInteresting && interestingSecondaryEntries.count == 1 {
            mainWikidataEntry = interestingSecondaryEntries[0]
            secondaryWikidataEntries = []
            Logger.info("Skipping \(wikidataEntry) for interesting secondary entry \(mainWikidataEntry)")
        } else {
            mainWikidataEntry = wikidataEntry
            secondaryWikidataEntries = interestingSecondaryEntries.isEmpty
                ? Array(wikidataEntry.secondaryWikidataEntries)
                : interestingSecondaryEntries
            if !isMainEntryInteresting && interestingSecondaryEntries.isEmpty {
                Logger.warning("Main \(WikidataEntry.self) \(wikidataEntry) is not interesting")
            }
            wikidataEntry.secondaryWikidataEntries
                .filter { !secondaryWikidataEntries.contains($0) }
                .forEach {
                    Logger.warning("Secondary \(WikidataEntry.self) \($0) is not interesting; skipping")
                }
        }

        guard let mainEntry = entry(wikidataEntry: mainWikidataEntry, realm: realm) else {
            return nil
        }

        let pointOfInterest = PointOfInterest.findOrCreate(id: wikidataEntry.id)(realm)

        pointOfInterest.name = openStreetMapElement.name
        pointOfInterest.openStreetMapElement = openStreetMapElement

        pointOfInterest.mainEntry = mainEntry
        pointOfInterest.secondaryEntries.removeAll()
        pointOfInterest.secondaryEntries.append(objectsIn: secondaryWikidataEntries
            .compactMap { self.entry(wikidataEntry: $0, realm: realm) })
        pointOfInterest.image = image

        return pointOfInterest
    }

    func entry(wikidataEntry: WikidataEntry, realm: Realm) -> Entry? {
        if wikidataEntry.kind == .person {
            guard wikidataEntry.dateOfBirth != nil else {
                Logger.warning("\(WikidataEntry.self) \(wikidataEntry) has no date of birth; skipping")
                return nil
            }
            guard wikidataEntry.dateOfDeath != nil else {
                Logger.warning("\(WikidataEntry.self) \(wikidataEntry) has no date of death; skipping")
                return nil
            }
        }

        let entry = Entry.findOrCreate(id: wikidataEntry.id)(realm)

        entry.name = wikidataEntry.name
        entry.kind = wikidataEntry.kind
        entry.dateOfBirth = wikidataEntry.dateOfBirth
        entry.dateOfDeath = wikidataEntry.dateOfDeath

        entry.image = wikidataEntry.image

        entry.categories.removeAll()
        entry.categories.append(objectsIn: categories(wikidataEntry: wikidataEntry, realm: realm))

        wikidataEntry.localizations.forEach { wikidataLocalizedEntry in
            let wikipediaPage = wikidataLocalizedEntry.wikipediaPage
            guard let name = wikidataLocalizedEntry.wikipediaPage?.wikipediaId?.title ??
                wikidataLocalizedEntry.name else {
                Logger.warning("\(WikidataLocalizedEntry.self) \(wikidataLocalizedEntry) has no name; skipping")
                return
            }
            guard let summary = wikidataLocalizedEntry.summary else {
                Logger.warning("\(WikidataLocalizedEntry.self) \(wikidataLocalizedEntry) has no summary; skipping")
                return
            }

            let localizedEntry = entry.findOrCreateLocalization(language: wikidataLocalizedEntry.language)(realm)
            localizedEntry.name = name
            localizedEntry.summary = summary
            localizedEntry.defaultSort = wikipediaPage?.defaultSort ?? name
            localizedEntry.wikipediaPage = wikipediaPage
        }

        return entry
    }

    func categories(wikidataEntry: WikidataEntry, realm: Realm) -> [Category] {
        let categories = wikidataEntry.wikidataCategories
            .flatMap { Array($0.categories) }
            .uniqueValues()
            .sorted { $0.id < $1.id }
        if wikidataEntry.kind == .person && categories.isEmpty {
            Logger.warning("\(WikidataEntry.self) \(wikidataEntry)  has no categories")
        }
        return categories
    }

    // MARK: Orphans

    func deleteOrphans(fetchedPointOfInterestIds: [String], realm: Realm) throws {
        // List existing objects
        var orphanedObjects: Set<PointOfInterest>
        switch scope {
        case .all:
            orphanedObjects = Set(PointOfInterest.all()(realm))
        case .single:
            orphanedObjects = Set()
        }

        orphanedObjects = orphanedObjects.filter { !fetchedPointOfInterestIds.contains($0.id) }

        if !orphanedObjects.isEmpty {
            Logger.info("Deleting \(orphanedObjects.count) \(PointOfInterest.self)(s)")
            orphanedObjects.forEach { $0.delete() }
        }

        try deleteOrphanedEntries(realm: realm)
    }

    func deleteOrphanedEntries(realm: Realm) throws {
        // List existing objects
        let orphanedObjects: Set<Entry>
        switch scope {
        case .all:
            orphanedObjects = Set(Entry.all()(realm).filter("mainEntryOf.@count == 0 && secondayEntryOf.@count == 0"))
        case .single:
            orphanedObjects = Set()
        }

        if !orphanedObjects.isEmpty {
            Logger.info("Deleting \(orphanedObjects.count) \(Entry.self)(s)")
            orphanedObjects.forEach { $0.delete() }
        }
    }

}

private extension WikidataEntry {

    func isInteresting() -> Bool {
        // An entry is interesting if it has a Wikipedia page on at least one localization
        return !localizations
            .compactMap { $0.wikipediaPage?.extract }
            .isEmpty
    }

}
