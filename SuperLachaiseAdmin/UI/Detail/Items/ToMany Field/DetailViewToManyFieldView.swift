//
//  DetailViewToManyFieldView.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 04/03/2018.
//

import Cocoa

final class DetailViewToManyFieldView: NSView {

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

    var value: [MainWindowModel] = [] {
        didSet {
            let views = value.flatMap { model -> NSView? in
                let view: DetailViewToManyFieldButton? = NSNib.instantiate("DetailViewToManyFieldButton")
                view?.value = model
                return view
            }
            stackView?.setViews(views, in: .top)
        }
    }

    // MARK: Subviews

    @IBOutlet private var nameLabel: NSTextField?

    @IBOutlet private var stackView: NSStackView?

    // MARK: Layout

    @IBOutlet private var nameWidthConstraint: NSLayoutConstraint?

    override func layout() {
        let nameWidth = nameWidthConstraint?.constant ?? 0
        nameLabel?.preferredMaxLayoutWidth = nameWidth
        super.layout()
    }

}
