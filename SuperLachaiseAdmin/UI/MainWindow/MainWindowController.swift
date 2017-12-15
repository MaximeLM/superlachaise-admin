//
//  MainWindowController.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 02/12/2017.
//

import Cocoa

final class MainWindowController: NSWindowController {

    var autosaveName: NSWindow.FrameAutosaveName? = NSWindow.FrameAutosaveName(rawValue: "MainWindow")

    override func windowDidLoad() {
        super.windowDidLoad()
        if let autosaveName = autosaveName {
            window?.setFrameUsingName(autosaveName)
            windowFrameAutosaveName = autosaveName
        }
    }

}
