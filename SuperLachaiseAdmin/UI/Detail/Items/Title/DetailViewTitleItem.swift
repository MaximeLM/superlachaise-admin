//
//  DetailViewTitleItem.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 17/12/2017.
//

import Cocoa

struct DetailViewTitleItem: DetailViewItem {

    let title: String

    var view: NSView? {
        let view: DetailViewTitleView? = NSNib.instantiate("DetailViewTitleView")
        view?.title = title
        return view
    }

}
