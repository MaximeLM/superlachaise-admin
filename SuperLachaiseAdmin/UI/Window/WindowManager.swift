//
//  WindowManager.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 15/12/2017.
//

import Cocoa

final class WindowManager: NSObject {

    static let shared = WindowManager()

    private var windowControllers: [NSWindowController] = []

    // Retain a window controller until its window is closed
    func retainWindowController(_ windowController: NSWindowController) {
        windowControllers.append(windowController)
        windowController.window?.delegate = self
    }

}

extension WindowManager: NSWindowDelegate {

    func windowWillClose(_ notification: Notification) {
        let window = notification.object as? NSWindow
        if let index = windowControllers.index(where: { $0.window == window }) {
            windowControllers.remove(at: index)
        }
    }

}
