//
//  DetailTitleView.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 17/12/2017.
//

import Cocoa

final class DetailTitleView: NSView {

    static func instantiate() -> DetailTitleView? {
        return NSNib.instantiate("DetailTitleView")
    }

    // MARK: Properties

    var title: String? {
        didSet {
            label?.stringValue = title ?? ""
        }
    }

    // MARK: Subviews

    @IBOutlet private weak var label: NSTextField?

    // MARK: Layout

    override func layout() {
        label?.preferredMaxLayoutWidth = bounds.width - 8
        super.layout()
    }

}
