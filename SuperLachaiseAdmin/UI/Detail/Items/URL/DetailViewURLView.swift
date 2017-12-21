//
//  DetailViewURLView.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 17/12/2017.
//

import Cocoa

final class DetailViewURLView: NSView {

    // MARK: Properties

    var url: URL? {
        didSet {
            if let url = url {
                label?.htmlStringValue = "<a href=\"\(url.absoluteString)\">\(url.absoluteString)</a>"
            } else {
                label?.stringValue = ""
            }
        }
    }

    // MARK: Subviews

    @IBOutlet private var label: NSTextField?

    // MARK: Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        label?.allowsEditingTextAttributes = true
        label?.isSelectable = true
    }

    // MARK: Layout

    override func layout() {
        label?.preferredMaxLayoutWidth = bounds.width - 2 * 20
        super.layout()
    }

}
