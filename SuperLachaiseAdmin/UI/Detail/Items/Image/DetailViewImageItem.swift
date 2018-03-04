//
//  DetailViewImageItem.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 04/03/2018.
//

import Cocoa

struct DetailViewImageItem: DetailViewItem {

    let url: URL?

    var view: NSView? {
        let view: DetailViewImageView? = NSNib.instantiate("DetailViewImageView")
        view?.url = url
        return view
    }

}
