//
//  AppDelegate.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 25/11/2017.
//

import Cocoa

@NSApplicationMain
final class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

}
