//
//  AppContainer.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 10/12/2017.
//

import Foundation
import RealmSwift

final class AppContainer {

    static var config: Config {
        return shared.config
    }

    static var realmContext: RealmContext {
        return shared.realmContext
    }

    static var taskController: TaskController {
        return shared.taskController
    }

    // MARK: Private

    private static let shared: AppContainer = {
        do {
            let appContainer = try AppContainer()
            Realm.Configuration.defaultConfiguration = appContainer.realmContext.configuration
            return appContainer
        } catch {
            fatalError("\(error)")
        }
    }()

    private let config: Config
    private let realmContext: RealmContext
    private let database: CoreDataDatabase
    private let taskController: TaskController

    private init() throws {
        guard let configURL = Bundle.main.url(forResource: "Config", withExtension: "plist") else {
            throw AppContainerError.configNotFound
        }
        let configData = try Data(contentsOf: configURL)

        self.config = try PropertyListDecoder().decode(Config.self, from: configData)
        self.realmContext = try RealmContext(databaseDirectoryName: "database", databaseFileName: "SuperLachaise")
        self.database = CoreDataDatabase(name: "SuperLachaiseAdmin")
        self.taskController = TaskController(config: config, realmContext: realmContext)
    }

}

enum AppContainerError: Error {
    case configNotFound
}
