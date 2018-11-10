//
//  AppContainer.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 10/12/2017.
//

import Foundation

final class AppContainer {

    static var config: Config {
        return shared.config
    }

    static var database: Database {
        return shared.database
    }

    static var taskController: TaskController {
        return shared.taskController
    }

    // MARK: Private

    private static let shared: AppContainer = {
        do {
            return try AppContainer()
        } catch {
            fatalError("\(error)")
        }
    }()

    private let config: Config
    private let database: Database
    private let taskController: TaskController

    private init() throws {
        guard let configURL = Bundle.main.url(forResource: "Config", withExtension: "plist") else {
            throw AppContainerError.configNotFound
        }
        let configData = try Data(contentsOf: configURL)

        self.config = try PropertyListDecoder().decode(Config.self, from: configData)
        self.database = Database(name: "SuperLachaiseAdmin")
        self.taskController = TaskController(config: config, database: database)
    }

}

enum AppContainerError: Error {
    case configNotFound
}
