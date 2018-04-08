//
//  SyncWikipediaPages.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 21/12/2017.
//

import Foundation
import RealmSwift
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

    let endpoint: (String) -> APIEndpointType

    init(scope: Scope, endpoint: @escaping (String) -> APIEndpointType) {
        self.scope = scope
        self.endpoint = endpoint
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

    private let realmDispatchQueue = DispatchQueue(label: "SyncWikipediaPages.realm")

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
            return Realm.async(dispatchQueue: realmDispatchQueue) { realm in
                return WikidataLocalizedEntry.all()(realm)
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
            .do(onSuccess: { Logger.info("Fetched \($0.count) \(WikipediaPage.self)(s)") })
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
        return Realm.async(dispatchQueue: realmDispatchQueue) { realm in
            try realm.write {
                try self.saveWikipediaPages(language: language, wikipediaAPIPages: wikipediaAPIPages, realm: realm)
            }
        }
    }

    func saveWikipediaPages(language: String, wikipediaAPIPages: [WikipediaAPIPage], realm: Realm) throws -> [String] {
        return try wikipediaAPIPages.map { wikipediaAPIPage in
            try self.wikipediaPage(language: language, wikipediaAPIPage: wikipediaAPIPage, realm: realm).rawWikipediaId
        }
    }

    // MARK: Wikipedia page

    func wikipediaPage(language: String, wikipediaAPIPage: WikipediaAPIPage, realm: Realm) throws -> WikipediaPage {
        // Wikipedia Id
        let wikipediaId = WikipediaId(language: language, title: wikipediaAPIPage.title)
        let wikipediaPage = WikipediaPage.findOrCreate(wikipediaId: wikipediaId)(realm)

        // Name
        wikipediaPage.name = wikipediaAPIPage.title

        // Default sort
        let defaultSort = self.defaultSort(wikipediaAPIPage: wikipediaAPIPage)
        if defaultSort == nil {
            Logger.warning("\(WikipediaPage.self) \(wikipediaPage) has no default sort")
        }
        wikipediaPage.defaultSort = defaultSort

        // Extract
        let extract = self.extract(wikipediaAPIPage: wikipediaAPIPage)
        if extract == nil {
            Logger.warning("\(WikipediaPage.self) \(wikipediaPage) has no extract")
        }
        wikipediaPage.extract = extract

        // Redirect
        if let redirect = self.redirect(wikipediaAPIPage: wikipediaAPIPage) {
            Logger.warning("\(WikipediaPage.self) \(wikipediaPage) is a redirect for \(redirect)")
        }

        return wikipediaPage
    }

    func extract(wikipediaAPIPage: WikipediaAPIPage) -> String? {
        guard var lines = wikipediaAPIPage.extract?.split(separator: "\n") else {
            return nil
        }

        // Remove leading and trailing white lines and empty paragraphs
        let emptyLines = [
            "",
            "<p></p>",
            "<p><br></p>",
            "<p><span></span></p>",
        ]
        lines = lines.filter({ !emptyLines.contains($0.trimmingCharacters(in: .whitespaces)) })

        guard !lines.isEmpty else {
            return nil
        }
        var extract = lines.joined(separator: "\n")

        // Remove unwanted strings
        extract = extract.replacingOccurrences(of: "<sup class=\"reference cite_virgule\">,</sup>", with: "")
        extract = extract.replacingOccurrences(of: " (<span><span><span> </span>listen</span></span>)", with: "")
        extract = extract.replacingOccurrences(of: "(<span></span>, ", with: "(")
        extract = extract.replacingOccurrences(of: "(<span></span>; ", with: "(")
        extract = extract.replacingOccurrences(of: "<br style=\"margin-bottom: 1ex;\"></p>", with: "</p>")
        extract = extract.replacingOccurrences(of: "</ul>", with: "</ul><br/>")
        extract = extract.replacingOccurrences(of: "<ul id=\"bandeau-portail\"",
                                               with: "<ul id=\"bandeau-portail\" style=\"display: none;\"")

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

    func deleteOrphans(fetchedRawWikipediaIds: [String]) -> Single<Void> {
        return Realm.async(dispatchQueue: realmDispatchQueue) { realm in
            try realm.write {
                try self.deleteOrphans(fetchedRawWikipediaIds: fetchedRawWikipediaIds, realm: realm)
            }
        }
    }

    func deleteOrphans(fetchedRawWikipediaIds: [String], realm: Realm) throws {
        // List existing objects
        var orphanedObjects: Set<WikipediaPage>
        switch scope {
        case .all:
            orphanedObjects = Set(WikipediaPage.all()(realm))
        case .single:
            orphanedObjects = Set()
        }

        orphanedObjects = orphanedObjects.filter { !fetchedRawWikipediaIds.contains($0.rawWikipediaId) }

        if !orphanedObjects.isEmpty {
            Logger.info("Deleting \(orphanedObjects.count) \(WikipediaPage.self)(s)")
            orphanedObjects.forEach { $0.delete() }
        }
    }

}
