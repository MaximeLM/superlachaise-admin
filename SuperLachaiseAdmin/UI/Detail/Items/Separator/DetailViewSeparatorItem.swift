//
//  DetailViewSeparatorItem.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 17/12/2017.
//

import Cocoa

struct DetailViewSeparatorItem: DetailViewItem {

    var view: NSView? {
        let view: NSView? = NSNib.instantiate("DetailViewSeparatorView")
        return view
    }

}
