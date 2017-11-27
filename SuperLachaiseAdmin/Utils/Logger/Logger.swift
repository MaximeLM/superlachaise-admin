//
//  Logger.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 26/11/2017.
//

import Foundation

final class Logger {

    static func info(_ message: String) {
        print("ℹ️ \(message)")
    }

    static func warning(_ message: String) {
        print("⚠️ \(message)")
    }

    static func error(_ message: String) {
        print("❌ \(message)")
    }

    static func success(_ message: String) {
        print("✅ \(message)")
    }

}
