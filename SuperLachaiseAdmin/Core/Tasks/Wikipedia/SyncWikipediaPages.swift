//
//  SyncWikipediaPages.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 21/12/2017.
//

import CoreData
import Foundation
import RxSwift

final class SyncWikipediaPages: Task {

    enum Scope: CustomStringConvertible {

        case all
        case single(wikipediaId: WikipediaId)

        var description: String {
            switch self {
            case .all:
                return "all"
            case let .single(wikipediaId):
                return wikipediaId.description
            }
        }

    }

    let scope: Scope
    let config: WikipediaConfig
    let endpoint: (String) -> APIEndpointType
    let performInBackground: Single<NSManagedObjectContext>

    init(scope: Scope,
         config: WikipediaConfig,
         endpoint: @escaping (String) -> APIEndpointType,
         performInBackground: Single<NSManagedObjectContext>) {
        self.scope = scope
        self.config = config
        self.endpoint = endpoint
        self.performInBackground = performInBackground
    }

    var description: String {
        return "\(type(of: self)) (\(scope.description))"
    }

    // MARK: Execution

    func asSingle() -> Single<Void> {
        return wikipediaPages()
            .flatMap(self.deleteOrphans)
    }

    // MARK: Private properties

    private lazy var defaultSortRegularExpression: NSRegularExpression? = {
        do {
            return try NSRegularExpression(pattern: "^[\\s]*\\{\\{DEFAULTSORT:(.*)\\}\\}[\\s]*$",
                                           options: [.anchorsMatchLines])
        } catch {
            assertionFailure("\(error)")
            return nil
        }
    }()

    private lazy var cleDeTriRegularExpression: NSRegularExpression? = {
        do {
            return try NSRegularExpression(pattern: "^[\\s]*\\{\\{CLEDETRI:(.*)\\}\\}[\\s]*$",
                                           options: [.anchorsMatchLines])
        } catch {
            assertionFailure("\(error)")
            return nil
        }
    }()

    private lazy var redirectRegularExpression: NSRegularExpression? = {
        do {
            return try NSRegularExpression(pattern: "^[\\s]*#REDIRECT[\\s]*\\[\\[(.*)\\]\\][\\s]*$",
                                           options: [.anchorsMatchLines])
        } catch {
            assertionFailure("\(error)")
            return nil
        }
    }()

}

private extension SyncWikipediaPages {

    // MARK: Wikipedia titles

    func wikipediaTitlesByLanguage() -> Single<[String: [String]]> {
        switch scope {
        case .all:
            // Get wikipedia titles from Wikidata localized entries
            return performInBackground.map { context in
                context.objects(CoreDataWikidataLocalizedEntry.self).fetch()
                    .reduce([:]) { partialResult, wikidataLocalizedEntry in
                        guard let wikipediaTitle = wikidataLocalizedEntry.wikipediaPage?.wikipediaId?.title else {
                            return partialResult
                        }
                        var partialResult = partialResult
                        if partialResult[wikidataLocalizedEntry.language] == nil {
                            partialResult[wikidataLocalizedEntry.language] = []
                        }
                        partialResult[wikidataLocalizedEntry.language]?.append(wikipediaTitle)
                        return partialResult
                    }
            }
        case let .single(wikipediaId):
            return Single.just([wikipediaId.language: [wikipediaId.title]])
        }
    }

    // MARK: Wikipedia API pages

    func wikipediaAPIPages(language: String, wikipediaTitles: [String]) -> Single<(String, [WikipediaAPIPage])> {
        return WikipediaGetPages(endpoint: endpoint(language), wikipediaTitles: wikipediaTitles)
            .asSingle()
            .map { (language, $0) }
    }

    // MARK: Wikipedia pages

    func wikipediaPages() -> Single<[String]> {
        return wikipediaTitlesByLanguage()
            .flatMap(self.wikipediaPages)
            .do(onSuccess: { Logger.info("Fetched \($0.count) \(CoreDataWikipediaPage.self)(s)") })
    }

    func wikipediaPages(wikipediaTitlesByLanguage: [String: [String]]) -> Single<[String]> {
        guard !wikipediaTitlesByLanguage.isEmpty else {
            return Single.just([])
        }
        // Make an observable for each language and combine the results
        let observables = wikipediaTitlesByLanguage.map(self.wikipediaPages).map { $0.asObservable() }
        return Observable.zip(observables) { $0.flatMap { $0 } }.asSingle()
    }

    func wikipediaPages(language: String, wikipediaTitles: [String]) -> Single<[String]> {
        return wikipediaAPIPages(language: language, wikipediaTitles: wikipediaTitles)
            .flatMap(self.saveWikipediaPages)
    }

    func saveWikipediaPages(language: String, wikipediaAPIPages: [WikipediaAPIPage]) -> Single<[String]> {
        return performInBackground.map { context in
            try context.write {
                try self.saveWikipediaPages(language: language,
                                            wikipediaAPIPages: wikipediaAPIPages,
                                            context: context)
            }
        }
    }

    func saveWikipediaPages(language: String,
                            wikipediaAPIPages: [WikipediaAPIPage],
                            context: NSManagedObjectContext) throws -> [String] {
        return try wikipediaAPIPages.map { wikipediaAPIPage in
            try self.wikipediaPage(language: language, wikipediaAPIPage: wikipediaAPIPage, context: context).id
        }
    }

    // MARK: Wikipedia page

    func wikipediaPage(language: String,
                       wikipediaAPIPage: WikipediaAPIPage,
                       context: NSManagedObjectContext) throws -> CoreDataWikipediaPage {
        // Wikipedia Id
        let wikipediaId = WikipediaId(language: language, title: wikipediaAPIPage.title)
        let wikipediaPage = context.findOrCreate(CoreDataWikipediaPage.self, key: wikipediaId)

        // Name
        wikipediaPage.name = wikipediaAPIPage.title

        // Default sort
        let defaultSort = self.defaultSort(wikipediaAPIPage: wikipediaAPIPage)
        if defaultSort == nil {
            Logger.warning("\(CoreDataWikipediaPage.self) \(wikipediaPage) has no default sort")
        }
        wikipediaPage.defaultSort = defaultSort

        // Extract
        let extract = self.extract(wikipediaAPIPage: wikipediaAPIPage)
        if extract == nil {
            Logger.warning("\(CoreDataWikipediaPage.self) \(wikipediaPage) has no extract")
        }
        wikipediaPage.extract = extract

        // Redirect
        if let redirect = self.redirect(wikipediaAPIPage: wikipediaAPIPage) {
            Logger.warning("\(CoreDataWikipediaPage.self) \(wikipediaPage) is a redirect for \(redirect)")
        }

        return wikipediaPage
    }

    func extract(wikipediaAPIPage: WikipediaAPIPage) -> String? {
        guard var extract = wikipediaAPIPage.extract else {
            return nil
        }

        extract = extract.replacingOccurrences(of: "\n", with: "")
        while extract.contains("  ") {
            extract = extract.replacingOccurrences(of: "  ", with: " ")
        }

        // Replace unwanted strings
        for substitutions in config.extractSubstitutions {
            for (key, value) in substitutions {
                extract = extract.replacingOccurrences(of: key, with: value)
            }
        }

        return extract
    }

    func defaultSort(wikipediaAPIPage: WikipediaAPIPage) -> String? {
        guard let wikitext = wikipediaAPIPage.revisions?.first?.wikitext else {
            return nil
        }

        let inputRange = NSRange(wikitext.startIndex..., in: wikitext)
        let regularExpressions = [defaultSortRegularExpression, cleDeTriRegularExpression]
        let match = regularExpressions.compactMap { $0?.firstMatch(in: wikitext, options: [], range: inputRange) }.first

        if let match = match, let range = Range(match.range(at: 1), in: wikitext) {
            return String(wikitext[range]).trimmingCharacters(in: .whitespacesAndNewlines)
        } else {
            return nil
        }
    }

    func redirect(wikipediaAPIPage: WikipediaAPIPage) -> String? {
        guard let wikitext = wikipediaAPIPage.revisions?.first?.wikitext else {
            return nil
        }

        let inputRange = NSRange(wikitext.startIndex..., in: wikitext)
        let regularExpressions = [redirectRegularExpression]
        let match = regularExpressions.compactMap { $0?.firstMatch(in: wikitext, options: [], range: inputRange) }.first

        if let match = match, let range = Range(match.range(at: 1), in: wikitext) {
            return String(wikitext[range]).trimmingCharacters(in: .whitespacesAndNewlines)
        } else {
            return nil
        }
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
        var orphanedObjects: Set<CoreDataWikipediaPage>
        switch scope {
        case .all:
            orphanedObjects = Set(context.objects(CoreDataWikipediaPage.self).fetch())
        case .single:
            orphanedObjects = Set()
        }

        orphanedObjects = orphanedObjects.filter { !fetchedIds.contains($0.id) }

        if !orphanedObjects.isEmpty {
            Logger.info("Deleting \(orphanedObjects.count) \(CoreDataWikipediaPage.self)(s)")
            orphanedObjects.forEach { context.delete($0) }
        }
    }

}
