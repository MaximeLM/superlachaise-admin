//
//  SyncCommonsCategories.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 20/02/2018.
//

import Foundation
import RealmSwift
import RxSwift

final class SyncCommonsCategories: Task {

    enum Scope: CustomStringConvertible {

        case all
        case single(commonsCategoryId: String)

        var description: String {
            switch self {
            case .all:
                return "all"
            case let .single(commonsCategoryId):
                return commonsCategoryId
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
        return commonsCategories()
            .flatMap(self.deleteOrphans)
    }

    // MARK: Private properties

    private let realmDispatchQueue = DispatchQueue(label: "SyncCommonsCategories.realm")

    private lazy var defaultSortRegularExpression: NSRegularExpression? = {
        do {
            return try NSRegularExpression(pattern: "^[\\s]*\\{\\{DEFAULTSORT:(.*)\\}\\}[\\s]*$",
                                           options: [.anchorsMatchLines])
        } catch {
            assertionFailure("\(error)")
            return nil
        }
    }()

    private lazy var mainCommonsFileIdRegularExpression: NSRegularExpression? = {
        do {
            return try NSRegularExpression(pattern: "^[\\s]*\\|image[\\s]*=[\\s]*(.*)[\\s]*$",
                                           options: [.anchorsMatchLines])
        } catch {
            assertionFailure("\(error)")
            return nil
        }
    }()

    private lazy var redirectRegularExpression: NSRegularExpression? = {
        do {
            return try NSRegularExpression(pattern: "^[\\s]*\\{\\{Category redirect\\|[\\s]*Category:(.*)\\}\\}[\\s]*$",
                                           options: [.anchorsMatchLines])
        } catch {
            assertionFailure("\(error)")
            return nil
        }
    }()

}

private extension SyncCommonsCategories {

    // MARK: Commons categories ids

    func commonsCategoriesIds() -> Single<[String]> {
        switch self.scope {
        case .all:
            // Get commons categories ids from Wikidata entries
            return Realm.async(dispatchQueue: realmDispatchQueue) { realm in
                return WikidataEntry.all()(realm).flatMap { $0.commonsCategoryId }
            }
        case let .single(commonsCategoryId):
            return Single.just([commonsCategoryId])
        }
    }

    // MARK: Commons API categories

    func commonsAPICategories(commonsCategoriesIds: [String]) -> Single<[CommonsAPICategory]> {
        return CommonsGetCategories(endpoint: endpoint, commonsCategoriesIds: commonsCategoriesIds)
            .asSingle()
    }

    // MARK: Commons categories

    func commonsCategories() -> Single<[String]> {
        return commonsCategoriesIds()
            .flatMap(self.commonsCategories)
            .do(onSuccess: { Logger.info("Fetched \($0.count) \(CommonsCategory.self)(s)") })
            .flatMap(self.withCategoryMembers)
    }

    func commonsCategories(commonsCategoriesIds: [String]) -> Single<[String]> {
        return commonsAPICategories(commonsCategoriesIds: commonsCategoriesIds)
            .flatMap(self.saveCommonsCategories)
    }

    func saveCommonsCategories(commonsAPICategories: [CommonsAPICategory]) -> Single<[String]> {
        return Realm.async(dispatchQueue: realmDispatchQueue) { realm in
            try realm.write {
                try self.saveCommonsCategories(commonsAPICategories: commonsAPICategories, realm: realm)
            }
        }
    }

    func saveCommonsCategories(commonsAPICategories: [CommonsAPICategory], realm: Realm) throws -> [String] {
        return try commonsAPICategories.map { commonsAPICategory in
            try self.commonsCategory(commonsAPICategory: commonsAPICategory, realm: realm).commonsCategoryId
        }
    }

    // MARK: Commons category

    func commonsCategory(commonsAPICategory: CommonsAPICategory, realm: Realm) throws -> CommonsCategory {
        // Commons category ID
        if !commonsAPICategory.title.hasPrefix("Category:") {
            Logger.warning("Invalid \(CommonsAPICategory.self) title: \(commonsAPICategory.title)")
        }
        let commonsCategoryId = String(commonsAPICategory.title.dropFirst(9))
        let commonsCategory = CommonsCategory.findOrCreate(commonsCategoryId: commonsCategoryId)(realm)
        commonsCategory.deleted = false

        // Default sort
        let defaultSort = self.defaultSort(commonsAPICategory: commonsAPICategory)
        if defaultSort == nil {
            Logger.warning("\(CommonsCategory.self) \(commonsCategory) has no default sort")
        }
        commonsCategory.defaultSort = defaultSort

        // Main Commons File Id
        let mainCommonsFileId = self.mainCommonsFileId(commonsAPICategory: commonsAPICategory)
        if mainCommonsFileId == nil {
            Logger.warning("\(CommonsCategory.self) \(commonsCategory) has no main Commons File Id")
        }
        commonsCategory.mainCommonsFileId = mainCommonsFileId

        // Redirect
        if let redirect = self.redirect(commonsAPICategory: commonsAPICategory) {
            Logger.warning("\(CommonsCategory.self) \(commonsCategory) is a redirect for \(redirect)")
        }

        return commonsCategory
    }

    func defaultSort(commonsAPICategory: CommonsAPICategory) -> String? {
        guard let wikitext = commonsAPICategory.revisions?.first?.wikitext else {
            return nil
        }

        let inputRange = NSRange(wikitext.startIndex..., in: wikitext)
        let regularExpressions = [defaultSortRegularExpression]
        let match = regularExpressions.flatMap { $0?.firstMatch(in: wikitext, options: [], range: inputRange) }.first

        if let match = match, let range = Range(match.range(at: 1), in: wikitext) {
            return String(wikitext[range]).trimmingCharacters(in: .whitespacesAndNewlines)
        } else {
            return nil
        }
    }

    func mainCommonsFileId(commonsAPICategory: CommonsAPICategory) -> String? {
        guard let wikitext = commonsAPICategory.revisions?.first?.wikitext else {
            return nil
        }

        let inputRange = NSRange(wikitext.startIndex..., in: wikitext)
        let regularExpressions = [mainCommonsFileIdRegularExpression]
        let match = regularExpressions.flatMap { $0?.firstMatch(in: wikitext, options: [], range: inputRange) }.first

        if let match = match, let range = Range(match.range(at: 1), in: wikitext) {
            return String(wikitext[range]).trimmingCharacters(in: .whitespacesAndNewlines)
        } else {
            return nil
        }
    }

    func redirect(commonsAPICategory: CommonsAPICategory) -> String? {
        guard let wikitext = commonsAPICategory.revisions?.first?.wikitext else {
            return nil
        }

        let inputRange = NSRange(wikitext.startIndex..., in: wikitext)
        let regularExpressions = [redirectRegularExpression]
        let match = regularExpressions.flatMap { $0?.firstMatch(in: wikitext, options: [], range: inputRange) }.first

        if let match = match, let range = Range(match.range(at: 1), in: wikitext) {
            return String(wikitext[range]).trimmingCharacters(in: .whitespacesAndNewlines)
        } else {
            return nil
        }
    }

    // MARK: Category members

    func withCategoryMembers(commonsCategoriesIds: [String]) -> Single<[String]> {
        return CommonsGetCategoryMembers(endpoint: endpoint, commonsCategoriesIds: commonsCategoriesIds)
            .asSingle()
            .flatMap(self.saveCategoryMembers)
    }

    func saveCategoryMembers(categoryMembers: [String: [CommonsAPICategoryMember]]) -> Single<[String]> {
        return Realm.async(dispatchQueue: realmDispatchQueue) { realm in
            try realm.write {
                try self.saveCategoryMembers(categoryMembers: categoryMembers, realm: realm)
            }
        }
    }

    func saveCategoryMembers(categoryMembers: [String: [CommonsAPICategoryMember]], realm: Realm) throws -> [String] {
        return try categoryMembers.map { commonsCategoryId, categoryMembers in
            try self.saveCategoryMembers(commonsCategoryId: commonsCategoryId,
                                         categoryMembers: categoryMembers,
                                         realm: realm).commonsCategoryId
        }
    }

    func saveCategoryMembers(commonsCategoryId: String,
                             categoryMembers: [CommonsAPICategoryMember],
                             realm: Realm) throws -> CommonsCategory {
        guard let commonsCategory = CommonsCategory.find(commonsCategoryId: commonsCategoryId)(realm) else {
            throw SyncCommonsCategoriesError.commonsCategoryNotFound(commonsCategoryId)
        }
        let commonsFilesIds = categoryMembers.map { categoryMember -> String in
            if !categoryMember.title.hasPrefix("File:") {
                Logger.warning("Invalid \(CommonsAPICategoryMember.self) title: \(categoryMember.title)")
            }
            return String(categoryMember.title.dropFirst(5))
        }
        commonsCategory.commonsFilesIds.replaceAll(objects: commonsFilesIds)
        return commonsCategory
    }

    // MARK: Orphans

    func deleteOrphans(fetchedCommonsCategoriesIds: [String]) -> Single<Void> {
        return Realm.async(dispatchQueue: realmDispatchQueue) { realm in
            try realm.write {
                try self.deleteOrphans(fetchedCommonsCategoriesIds: fetchedCommonsCategoriesIds, realm: realm)
            }
        }
    }

    func deleteOrphans(fetchedCommonsCategoriesIds: [String], realm: Realm) throws {
        // List existing objects
        var orphanedObjects: Set<CommonsCategory>
        switch scope {
        case .all:
            orphanedObjects = Set(CommonsCategory.all()(realm))
        case .single:
            orphanedObjects = Set()
        }

        orphanedObjects = orphanedObjects.filter { !fetchedCommonsCategoriesIds.contains($0.commonsCategoryId) }

        if !orphanedObjects.isEmpty {
            orphanedObjects.forEach { $0.deleted = true }
            Logger.info("Flagged \(orphanedObjects.count) \(CommonsCategory.self)(s) for deletion")
        }
    }

}

enum SyncCommonsCategoriesError: Error {
    case commonsCategoryNotFound(String)
}
