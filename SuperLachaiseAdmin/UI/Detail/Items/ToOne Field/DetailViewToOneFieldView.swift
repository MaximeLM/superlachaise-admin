//
//  DetailViewToOneFieldView.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 04/03/2018.
//

import Cocoa

final class DetailViewToOneFieldView: NSView {

    // MARK: Properties

    var name: String? {
        didSet {
            if let name = name {
                nameLabel?.stringValue = name
            } else {
                nameLabel?.stringValue = ""
            }
        }
    }

    var value: MainWindowModel? {
        didSet {
            if let value = value {
                valueButton?.isHidden = false
                valueButton?.title = "\(value)"
            } else {
                valueButton?.isHidden = true
                valueButton?.title = ""
            }
        }
    }

    // MARK: Subviews

    @IBOutlet private var nameLabel: NSTextField?

    @IBOutlet private var valueButton: NSButton?

    // MARK: Layout

    @IBOutlet private var nameWidthConstraint: NSLayoutConstraint?

    override func layout() {
        let nameWidth = nameWidthConstraint?.constant ?? 0
        nameLabel?.preferredMaxLayoutWidth = nameWidth
        super.layout()
    }

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
