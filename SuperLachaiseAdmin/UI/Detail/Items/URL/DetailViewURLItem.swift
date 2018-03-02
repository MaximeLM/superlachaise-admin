//
//  DetailViewURLItem.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 17/12/2017.
//

import Cocoa

struct DetailViewURLItem: DetailViewItem {

    let url: URL?

    var view: NSView? {
        let view: DetailViewURLView? = NSNib.instantiate("DetailViewURLView")
        view?.url = url
        return view
    }

}
