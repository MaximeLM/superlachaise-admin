//
//  DetailViewFieldView.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 17/12/2017.
//

import Cocoa

final class DetailViewFieldView: NSView {

    static func instantiate(name: String, value: Any?) -> DetailViewFieldView? {
        let view: DetailViewFieldView? = NSNib.instantiate("DetailViewFieldView")
        view?.name = name
        view?.value = value
        return view
    }

    // MARK: Properties

    var name: String? {
        didSet {
            if let name = name {
                nameLabel?.stringValue = "\(name):"
            } else {
                nameLabel?.stringValue = ""
            }
        }
    }

    var value: Any? {
        didSet {
            if let value = value {
                valueLabel?.stringValue = "\(value)"
            } else {
                valueLabel?.stringValue = ""
            }
        }
    }

    // MARK: Subviews

    @IBOutlet private weak var nameLabel: NSTextField?

    @IBOutlet private weak var valueLabel: NSTextField?

    // MARK: Layout

    @IBOutlet private weak var nameWidthConstraint: NSLayoutConstraint?

    override func layout() {
        let nameWidth = nameWidthConstraint?.constant ?? 0
        nameLabel?.preferredMaxLayoutWidth = nameWidth
        valueLabel?.preferredMaxLayoutWidth = bounds.width - nameWidth - 3 * 8
        super.layout()
    }

}
