//
//  DetailViewHTMLFieldItem.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 17/12/2017.
//

import Cocoa

struct DetailViewHTMLFieldItem: DetailViewItem {

    let name: String

    let value: Any?

    var view: NSView? {
        let view: DetailViewHTMLFieldView? = NSNib.instantiate("DetailViewHTMLFieldView")
        view?.name = name
        view?.value = value
        return view
    }

}
