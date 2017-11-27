//
//  UserAgent.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 28/11/2017.
//

import Foundation

final class UserAgent {

    static let `default`: String = {
        let infoDictionary = Bundle.main.infoDictionary
        guard let name = infoDictionary?["CFBundleName"] as? String,
            let version = infoDictionary?["CFBundleShortVersionString"] as? String,
            let build = infoDictionary?["CFBundleVersion"] as? String else {
                fatalError("Missing required field in Info.plist")
        }
        let contact = "https://github.com/MaximeLM/superlachaise-admin"
        return "\(name)/\(version)(\(build)) - \(contact)"
    }()

}
