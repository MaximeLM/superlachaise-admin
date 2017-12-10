//
//  AppContainer.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 10/12/2017.
//

import Foundation
import RealmSwift

final class AppContainer {

    static let config: Config = PereLachaiseConfig()

    static let realmContext: RealmContext = {
        do {
            let realmContext = try RealmContext(databaseDirectoryName: "database", databaseFileName: "SuperLachaise")
            Realm.Configuration.defaultConfiguration = realmContext.configuration
            return realmContext
        } catch {
            fatalError("\(error)")
        }
    }()

    static let taskController: TaskController = TaskController(config: config, realmContext: realmContext)

}
