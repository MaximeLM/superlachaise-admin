//
//  MainWindowController.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 02/12/2017.
//

import Cocoa

final class MainWindowController: NSWindowController, NSWindowDelegate {

    // MARK: Properties

    private var autosaveName: NSWindow.FrameAutosaveName? = NSWindow.FrameAutosaveName(rawValue: "MainWindow")

    // MARK: Subviews

    @IBOutlet weak var navigationSegmentedControl: NSSegmentedControl?

    // MARK: Lifecycle

    override func windowDidLoad() {
        super.windowDidLoad()
        if let autosaveName = autosaveName {
            window?.setFrameUsingName(autosaveName)
            windowFrameAutosaveName = autosaveName
        }

        // Keep the instance alive until the window closes
        MainWindowController.retain(self)

        window?.titleVisibility = .hidden

    }

    func windowWillClose(_ notification: Notification) {
        MainWindowController.release(self)
    }

    // MARK: New windows

    override func newWindowForTab(_ sender: Any?) {
        newTab(sender)
    }

    @IBAction func newTab(_ sender: Any?) {
        guard let newWindow = self.newWindow() else {
            return
        }
        window?.addTabbedWindow(newWindow, ordered: .above)
        newWindow.makeKeyAndOrderFront(self)
    }

    @IBAction func newWindow(_ sender: Any?) {
        guard let newWindow = self.newWindow() else {
            return
        }
        window?.addTabbedWindow(newWindow, ordered: .above)
        newWindow.moveTabToNewWindow(self)
        newWindow.makeKeyAndOrderFront(self)
    }

    private func newWindow() -> NSWindow? {
        guard let newWindowController = storyboard?.instantiateInitialController() as? MainWindowController else {
            return nil
        }
        newWindowController.autosaveName = nil
        return newWindowController.window
    }

    // MARK: Instances

    private static var instances: [MainWindowController] = []

    private static func retain(_ windowController: MainWindowController) {
        instances.append(windowController)
    }

    private static func release(_ windowController: MainWindowController) {
        if let index = instances.index(where: { $0 == windowController }) {
            instances.remove(at: index)
        }
    }

}
