//
//  DetailViewInlineFieldView.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 17/12/2017.
//

import Cocoa

final class DetailViewInlineFieldView: NSView {

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

    var valueViews: [NSView] = [] {
        didSet {
            stackView?.setViews(valueViews, in: .top)
        }
    }

    // MARK: Subviews

    @IBOutlet private weak var nameLabel: NSTextField?

    @IBOutlet private weak var stackView: NSStackView?

    // MARK: Layout

    @IBOutlet private weak var nameWidthConstraint: NSLayoutConstraint?

    override func layout() {
        let nameWidth = nameWidthConstraint?.constant ?? 0
        nameLabel?.preferredMaxLayoutWidth = nameWidth
        super.layout()
    }

}
