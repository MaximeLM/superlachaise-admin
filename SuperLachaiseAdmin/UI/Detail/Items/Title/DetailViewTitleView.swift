//
//  DetailViewTitleView.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 17/12/2017.
//

import Cocoa

final class DetailViewTitleView: NSView {

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
        label?.preferredMaxLayoutWidth = bounds.width - 2 * 20
        super.layout()
    }

}
