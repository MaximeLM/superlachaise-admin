//
//  MainWindowController.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 02/12/2017.
//

import Cocoa

final class MainWindowController: NSWindowController, NSWindowDelegate {

    // MARK: Properties

    var retainedSelf: MainWindowController?

    static var isFirstWindow = true

    // MARK: Subviews

    @IBOutlet weak var navigationSegmentedControl: NSSegmentedControl?

    @IBOutlet weak var titleLabel: NSTextField?

    // MARK: Lifecycle

    override func windowDidLoad() {
        super.windowDidLoad()

        if MainWindowController.isFirstWindow {
            MainWindowController.isFirstWindow = false
            let autosaveName = NSWindow.FrameAutosaveName(rawValue: "MainWindow")
            window?.setFrameUsingName(autosaveName)
            windowFrameAutosaveName = autosaveName
        }

        // Keep the instance alive until the window closes
        retainedSelf = self

        window?.titleVisibility = .hidden

    }

    func windowWillClose(_ notification: Notification) {
        retainedSelf = nil
    }

}
