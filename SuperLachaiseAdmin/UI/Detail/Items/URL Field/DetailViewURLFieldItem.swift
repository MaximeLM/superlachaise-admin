//
//  DetailViewURLFieldItem.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 03/03/2018.
//

import Cocoa

struct DetailViewURLFieldItem: DetailViewItem {

    let name: String

    let value: URL?

    var view: NSView? {
        let view: DetailViewURLFieldView? = NSNib.instantiate("DetailViewURLFieldView")
        view?.name = name
        view?.value = value
        return view
    }

}
