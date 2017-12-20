//
//  Logger.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 26/11/2017.
//

import Foundation

protocol LoggerType {

    func debug(_ message: String)
    func info(_ message: String)
    func warning(_ message: String)
    func error(_ message: String)
    func success(_ message: String)

}

struct Logger {

    static var shared: LoggerType = ConsoleLogger()

    static func debug(_ message: String) {
        shared.debug(message)
    }

    static func info(_ message: String) {
        shared.info(message)
    }

    static func warning(_ message: String) {
        shared.warning(message)
    }

    static func error(_ message: String) {
        shared.error(message)
    }

    static func success(_ message: String) {
        shared.success(message)
    }

}
