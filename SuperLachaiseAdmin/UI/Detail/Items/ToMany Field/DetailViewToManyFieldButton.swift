//
//  DetailViewToManyFieldButton.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 05/03/2018.
//

import Cocoa

final class DetailViewToManyFieldButton: NSView {

    var value: MainWindowModel? {
        didSet {
            if let value = value {
                button?.title = "\(value)"
            } else {
                button?.title = ""
            }
        }
    }

    // MARK: Subviews

    @IBOutlet private var button: NSButton?

    // MARK: Action

    @IBAction func navigate(_ sender: Any?) {
        guard let value = value else {
            return
        }
        if NSApp.currentEvent?.modifierFlags.contains(.command) ?? false {
            mainWindowController?.selectModelInNewTab(value)
        } else {
            mainWindowController?.selectModelIfNeeded(value)
        }
    }

}
