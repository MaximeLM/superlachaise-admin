//
//  DetailViewURLView.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 17/12/2017.
//

import Cocoa

final class DetailViewURLView: NSView {

    static func instantiate(url: URL) -> DetailViewURLView? {
        let view: DetailViewURLView? = NSNib.instantiate("DetailViewURLView")
        view?.url = url
        return view
    }

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

    @IBOutlet private weak var label: NSTextField?

    // MARK: Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        label?.allowsEditingTextAttributes = true
        label?.isSelectable = true
    }

    override func layout() {
        label?.preferredMaxLayoutWidth = bounds.width - 2 * 8
        super.layout()
    }

}
