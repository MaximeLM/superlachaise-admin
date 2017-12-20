//
//  MainWindowController+NewWindow.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 20/12/2017.
//

import Cocoa

extension MainWindowController {

    func newWindowController() -> MainWindowController? {
        return storyboard?.instantiateInitialController() as? MainWindowController
    }

    override func newWindowForTab(_ sender: Any?) {
        newTab(sender)
    }

    @IBAction func newTab(_ sender: Any?) {
        guard let newWindow = newWindowController()?.window else {
            return
        }
        window?.addTabbedWindow(newWindow, ordered: .above)
        newWindow.makeKeyAndOrderFront(self)
    }

    @IBAction func newWindow(_ sender: Any?) {
        guard let newWindow = newWindowController()?.window else {
            return
        }
        window?.addTabbedWindow(newWindow, ordered: .above)
        newWindow.moveTabToNewWindow(self)
        newWindow.makeKeyAndOrderFront(self)
    }

}
