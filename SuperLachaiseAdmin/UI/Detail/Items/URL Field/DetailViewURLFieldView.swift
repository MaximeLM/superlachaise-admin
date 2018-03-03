//
//  DetailViewURLFieldView.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 03/03/2018.
//

import Cocoa

final class DetailViewURLFieldView: NSView {

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

    var value: URL? {
        didSet {
            if let value = value {
                valueLabel?.htmlStringValue = "<a href=\"\(value.absoluteString)\">\(value.absoluteString)</a>"
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
