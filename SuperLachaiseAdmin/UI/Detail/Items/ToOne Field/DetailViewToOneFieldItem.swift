//
//  DetailViewToOneFieldItem.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 04/03/2018.
//

import Cocoa

struct DetailViewToOneFieldItem: DetailViewItem {

    let name: String

    let value: MainWindowModel?

    var view: NSView? {
        let view: DetailViewToOneFieldView? = NSNib.instantiate("DetailViewToOneFieldView")
        view?.name = name
        view?.value = value
        return view
    }

}
