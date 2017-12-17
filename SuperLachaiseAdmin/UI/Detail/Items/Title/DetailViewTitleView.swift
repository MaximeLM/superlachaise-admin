//
//  DetailViewTitleView.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 17/12/2017.
//

import Cocoa

final class DetailViewTitleView: NSView {

    static func instantiate(title: String) -> DetailViewTitleView? {
        let view: DetailViewTitleView? = NSNib.instantiate("DetailViewTitleView")
        view?.title = title
        return view
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
        label?.preferredMaxLayoutWidth = bounds.width - 2 * 8
        super.layout()
    }

}
