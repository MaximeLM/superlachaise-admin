//
//  SyncSuperLachaiseObjects.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 24/03/2018.
//

import CoreData
import Foundation
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
    let performInBackground: Single<NSManagedObjectContext>

    init(scope: Scope, performInBackground: Single<NSManagedObjectContext>) {
        self.scope = scope
        self.performInBackground = performInBackground
    }

    var description: String {
        return "\(type(of: self)) (\(scope.description))"
    }

    // MARK: Execution

    func asSingle() -> Single<Void> {
        return performInBackground.map { context in
            try context.write {
                let pointsOfInterest = self.syncPointsOfInterest(context: context)
                try self.deleteOrphans(fetchedPointOfInterestIds: pointsOfInterest.map { $0.id }, context: context)
            }
        }
    }

}

private extension SyncSuperLachaiseObjects {

    func syncPointsOfInterest(context: NSManagedObjectContext) -> [CoreDataPointOfInterest] {
        let pointsOfInterest = openStreetMapElements(context: context)
            .compactMap { openStreetMapElement -> CoreDataPointOfInterest? in
                guard let wikidataEntry = openStreetMapElement.wikidataEntry else {
                    Logger.warning(
                        "\(CoreDataOpenStreetMapElement.self) \(openStreetMapElement) has no wikidata entry; skipping")
                    return nil
                }
                return pointOfInterest(openStreetMapElement: openStreetMapElement,
                                       wikidataEntry: wikidataEntry,
                                       context: context)
            }

        let crossReference = Dictionary(grouping: pointsOfInterest, by: { $0 })
        let duplicates = crossReference.filter { $0.value.count > 1 }
        for duplicate in duplicates {
            Logger.warning("""
                \(CoreDataPointOfInterest.self) \(duplicate.key) is referenced by multiple OpenStreetMap elements; \
                skipping
                """)
        }
        return pointsOfInterest.filter({ !duplicates.keys.contains($0) })
    }

    func openStreetMapElements(context: NSManagedObjectContext) -> [CoreDataOpenStreetMapElement] {
        switch self.scope {
        case .all:
            return context.objects(CoreDataOpenStreetMapElement.self).fetch()
        case let .single(id):
            return context.objects(CoreDataOpenStreetMapElement.self)
                .filtered(by: "wikidataEntry.id == %@", [id])
                .fetch()
        }
    }

    func pointOfInterest(openStreetMapElement: CoreDataOpenStreetMapElement,
                         wikidataEntry: CoreDataWikidataEntry,
                         context: NSManagedObjectContext) -> CoreDataPointOfInterest? {
        guard let kind = wikidataEntry.kind else {
            Logger.warning("\(CoreDataWikidataEntry.self) \(wikidataEntry) for main entry has no kind; skipping")
            return nil
        }
        guard let image = (kind == .person) ? wikidataEntry.imageOfGrave : wikidataEntry.image else {
            Logger.warning("\(CoreDataWikidataEntry.self) \(wikidataEntry) for main entry has no image; skipping")
            return nil
        }

        let isMainEntryInteresting = wikidataEntry.isInteresting()
        let interestingSecondaryEntries = Array(wikidataEntry.secondaryWikidataEntries.filter { $0.isInteresting() })

        let mainWikidataEntry: CoreDataWikidataEntry
        let secondaryWikidataEntries: [CoreDataWikidataEntry]
        if kind == .grave && interestingSecondaryEntries.count == 1 {
            mainWikidataEntry = interestingSecondaryEntries[0]
            secondaryWikidataEntries = []
            Logger.info("Skipping \(wikidataEntry) for interesting secondary entry \(mainWikidataEntry)")
        } else {
            mainWikidataEntry = wikidataEntry
            secondaryWikidataEntries = interestingSecondaryEntries.isEmpty
                ? Array(wikidataEntry.secondaryWikidataEntries)
                : interestingSecondaryEntries
            if !isMainEntryInteresting && interestingSecondaryEntries.isEmpty {
                Logger.warning("Main \(CoreDataWikidataEntry.self) \(wikidataEntry) is not interesting")
            }
            wikidataEntry.secondaryWikidataEntries
                .filter { !secondaryWikidataEntries.contains($0) }
                .forEach {
                    Logger.warning("Secondary \(CoreDataWikidataEntry.self) \($0) is not interesting; skipping")
                }
        }

        guard let mainEntry = entry(wikidataEntry: mainWikidataEntry, context: context) else {
            return nil
        }

        let pointOfInterest = context.findOrCreate(CoreDataPointOfInterest.self, key: wikidataEntry.id)

        pointOfInterest.name = openStreetMapElement.name
        pointOfInterest.openStreetMapElement = openStreetMapElement

        pointOfInterest.mainEntry = mainEntry
        pointOfInterest.secondaryEntries = Set(secondaryWikidataEntries
            .compactMap { self.entry(wikidataEntry: $0, context: context) })
        pointOfInterest.image = image

        return pointOfInterest
    }

    func entry(wikidataEntry: CoreDataWikidataEntry, context: NSManagedObjectContext) -> CoreDataEntry? {
        if wikidataEntry.kind == .person {
            guard wikidataEntry.dateOfBirth != nil else {
                Logger.warning("\(CoreDataWikidataEntry.self) \(wikidataEntry) has no date of birth; skipping")
                return nil
            }
            guard wikidataEntry.dateOfDeath != nil else {
                Logger.warning("\(CoreDataWikidataEntry.self) \(wikidataEntry) has no date of death; skipping")
                return nil
            }
        }

        let entry = context.findOrCreate(CoreDataEntry.self, key: wikidataEntry.id)

        entry.name = wikidataEntry.name
        entry.kind = wikidataEntry.kind
        entry.dateOfBirth = wikidataEntry.dateOfBirth
        entry.dateOfDeath = wikidataEntry.dateOfDeath

        entry.image = wikidataEntry.image

        entry.categories = Set(categories(wikidataEntry: wikidataEntry, context: context))

        wikidataEntry.localizations.forEach { wikidataLocalizedEntry in
            let wikipediaPage = wikidataLocalizedEntry.wikipediaPage
            guard let name = wikidataLocalizedEntry.wikipediaPage?.wikipediaId?.title ??
                wikidataLocalizedEntry.name else {
                    Logger.warning("\(CoreDataWikidataLocalizedEntry.self) \(wikidataLocalizedEntry) has no name; skipping")
                    return
            }
            guard let summary = wikidataLocalizedEntry.summary else {
                Logger.warning("\(CoreDataWikidataLocalizedEntry.self) \(wikidataLocalizedEntry) has no summary; skipping")
                return
            }

            let localizedEntry = context.findOrCreate(CoreDataLocalizedEntry.self,
                                                      key: (entry: entry, language: wikidataLocalizedEntry.language))
            localizedEntry.name = name
            localizedEntry.summary = summary
            localizedEntry.defaultSort = wikipediaPage?.defaultSort ?? name
            localizedEntry.wikipediaPage = wikipediaPage
        }

        return entry
    }

    func categories(wikidataEntry: CoreDataWikidataEntry, context: NSManagedObjectContext) -> [CoreDataCategory] {
        let categories = wikidataEntry.wikidataCategories
            .flatMap { Array($0.categories) }
            .uniqueValues()
            .sorted { $0.id < $1.id }
        if wikidataEntry.kind == .person && categories.isEmpty {
            Logger.warning("\(CoreDataWikidataEntry.self) \(wikidataEntry)  has no categories")
        }
        return categories
    }

    // MARK: Orphans

    func deleteOrphans(fetchedPointOfInterestIds: [String], context: NSManagedObjectContext) throws {
        // List existing objects
        var orphanedObjects: Set<CoreDataPointOfInterest>
        switch scope {
        case .all:
            orphanedObjects = Set(context.objects(CoreDataPointOfInterest.self).fetch())
        case .single:
            orphanedObjects = Set()
        }

        orphanedObjects = orphanedObjects.filter { !fetchedPointOfInterestIds.contains($0.id) }

        if !orphanedObjects.isEmpty {
            Logger.info("Deleting \(orphanedObjects.count) \(CoreDataPointOfInterest.self)(s)")
            orphanedObjects.forEach { context.delete($0) }
        }

        try deleteOrphanedEntries(context: context)
    }

    func deleteOrphanedEntries(context: NSManagedObjectContext) throws {
        // List existing objects
        let orphanedObjects: Set<CoreDataEntry>
        switch scope {
        case .all:
            orphanedObjects = Set(context.objects(CoreDataEntry.self)
                .filtered(by: "mainEntryOf.@count == 0 && secondaryEntryOf.@count == 0")
                .fetch())
        case .single:
            orphanedObjects = Set()
        }

        if !orphanedObjects.isEmpty {
            Logger.info("Deleting \(orphanedObjects.count) \(CoreDataEntry.self)(s)")
            orphanedObjects.forEach { context.delete($0) }
        }
    }

}

private extension CoreDataWikidataEntry {

    func isInteresting() -> Bool {
        // An entry is interesting if it has a Wikipedia page on at least one localization
        return !localizations
            .compactMap { $0.wikipediaPage?.extract }
            .isEmpty
    }

}
