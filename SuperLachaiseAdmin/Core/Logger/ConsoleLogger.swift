//
//  ConsoleLogger.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 10/12/2017.
//

import Foundation

struct ConsoleLogger: LoggerType {

    func debug(_ message: String) {
        print("💬 \(message)")
    }

    func info(_ message: String) {
        print("ℹ️ \(message)")
    }

    func warning(_ message: String) {
        print("⚠️ \(message)")
    }

    func error(_ message: String) {
        print("❌ \(message)")
    }

    func success(_ message: String) {
        print("✅ \(message)")
    }

}
