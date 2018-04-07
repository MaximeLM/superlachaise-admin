//
//  DetailViewInlineFieldItem.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 17/12/2017.
//

import Cocoa

struct DetailViewInlineFieldItem: DetailViewItem {

    let name: String

    let valueItems: [DetailViewItem]

    var view: NSView? {
        let view: DetailViewInlineFieldView? = NSNib.instantiate("DetailViewInlineFieldView")
        view?.name = name
        view?.valueViews = valueItems.compactMap { $0.view }
        return view
    }

}
