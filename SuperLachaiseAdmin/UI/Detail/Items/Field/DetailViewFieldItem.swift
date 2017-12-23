//
//  DetailViewFieldItem.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 17/12/2017.
//

import Cocoa

struct DetailViewFieldItem: DetailViewItem {

    let name: String

    let value: Any?

    let isHTML: Bool

    init(name: String, value: Any?, isHTML: Bool = false) {
        self.name = name
        self.value = value
        self.isHTML = isHTML
    }

    var view: NSView? {
        let view: DetailViewFieldView? = NSNib.instantiate("DetailViewFieldView")
        view?.name = name
        if isHTML {
            view?.htmlValue = value
        } else {
            view?.value = value
        }
        return view
    }

}
