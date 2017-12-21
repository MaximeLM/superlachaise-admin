//
//  MainWindowController+NewWindow.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 20/12/2017.
//

import Cocoa

extension MainWindowController {

    func instantiate(model: MainWindowModel? = nil) -> MainWindowController? {
        let newWindowController = storyboard?.instantiateInitialController() as? MainWindowController
        newWindowController?.model.value = model
        return newWindowController
    }

    func newTab(_ windowController: MainWindowController?) {
        guard let newWindow = windowController?.window else {
            return
        }
        window?.addTabbedWindow(newWindow, ordered: .above)
        newWindow.makeKeyAndOrderFront(self)
    }

    func newWindow(_ windowController: MainWindowController?) {
        guard let newWindow = windowController?.window else {
            return
        }
        window?.addTabbedWindow(newWindow, ordered: .above)
        newWindow.moveTabToNewWindow(self)
        newWindow.makeKeyAndOrderFront(self)
    }

    override func newWindowForTab(_ sender: Any?) {
        newTab(instantiate())
    }

    @IBAction func newTab(_ sender: Any?) {
        newTab(instantiate())
    }

    @IBAction func newWindow(_ sender: Any?) {
        newWindow(instantiate())
    }

}
