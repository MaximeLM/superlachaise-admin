//
//  RootViewController+Actions.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 29/11/2017.
//

import Cocoa

extension RootViewController {

    // MARK: Windows

    override func newWindowForTab(_ sender: Any?) {
        newTab(sender)
    }

    @IBAction func newTab(_ sender: Any?) {
        guard let newWindow = self.newWindow() else {
            return
        }
        view.window?.addTabbedWindow(newWindow, ordered: .above)
        newWindow.makeKeyAndOrderFront(self)
    }

    @IBAction func newWindow(_ sender: Any?) {
        guard let newWindow = self.newWindow() else {
            return
        }
        view.window?.addTabbedWindow(newWindow, ordered: .above)
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

    // MARK: Sync

    @IBAction func syncOpenStreetMapElements(_ sender: Any?) {
        taskController.syncOpenStreetMapElements()
    }

    @IBAction func syncWikidataEntries(_ sender: Any?) {
        taskController.syncWikidataEntries()
    }

}
