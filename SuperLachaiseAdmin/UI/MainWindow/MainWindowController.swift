//
//  MainWindowController.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 02/12/2017.
//

import Cocoa

final class MainWindowController: NSWindowController {

    private let autosaveName = NSWindow.FrameAutosaveName(rawValue: "MainWindow")

    override func windowDidLoad() {
        super.windowDidLoad()
        window?.setFrameUsingName(autosaveName)
        windowFrameAutosaveName = autosaveName
    }

}
