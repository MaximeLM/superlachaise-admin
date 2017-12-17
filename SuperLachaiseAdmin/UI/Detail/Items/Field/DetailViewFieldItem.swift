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

    var view: NSView? {
        let view: DetailViewFieldView? = NSNib.instantiate("DetailViewFieldView")
        view?.name = name
        view?.value = value
        return view
    }

}
