//
//  DetailViewHTMLFieldView.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 17/12/2017.
//

import Cocoa

final class DetailViewHTMLFieldView: NSView {

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

    var value: Any? {
        didSet {
            if let value = value {
                valueLabel?.htmlStringValue = "\(value)"
            } else {
                valueLabel?.stringValue = ""
            }
        }
    }

    // MARK: Subviews

    @IBOutlet private var nameLabel: NSTextField?

    @IBOutlet private var valueLabel: NSTextField?

    // MARK: Layout

    @IBOutlet private var nameWidthConstraint: NSLayoutConstraint?

    override func layout() {
        let nameWidth = nameWidthConstraint?.constant ?? 0
        nameLabel?.preferredMaxLayoutWidth = nameWidth
        valueLabel?.preferredMaxLayoutWidth = bounds.width - nameWidth - 2 * 20 - 3 * 8
        super.layout()
    }

    // MARK: Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        valueLabel?.allowsEditingTextAttributes = true
    }

}
