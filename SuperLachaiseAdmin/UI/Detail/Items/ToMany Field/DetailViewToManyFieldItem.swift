//
//  DetailViewToManyFieldItem.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 05/03/2018.
//

import Cocoa

struct DetailViewToManyFieldItem: DetailViewItem {

    let name: String

    let value: [MainWindowModel]

    var view: NSView? {
        let view: DetailViewToManyFieldView? = NSNib.instantiate("DetailViewToManyFieldView")
        view?.name = name
        view?.value = value
        return view
    }

}
