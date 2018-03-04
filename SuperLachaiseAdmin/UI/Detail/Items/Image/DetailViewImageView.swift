//
//  DetailViewImageView.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 04/03/2018.
//

import Cocoa
import SDWebImage

final class DetailViewImageView: NSView {

    // MARK: Properties

    var url: URL? {
        didSet {
            if let url = url {
                imageView?.sd_setImage(with: url, completed: nil)
            } else {
                imageView?.image = nil
            }
        }
    }

    // MARK: Subviews

    @IBOutlet private var imageView: NSImageView?

}
