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

    var commonsFile: CommonsFile? {
        didSet {
            if let commonsFile = commonsFile {
                imageView?.sd_setImage(with: commonsFile.thumbnailURL(height: 400), completed: nil)
                if let imageViewWidth = imageViewWidth, let imageViewHeight = imageViewHeight,
                    commonsFile.width > 0, commonsFile.height > 0 {
                    imageViewWidth.constant = imageViewHeight.constant * CGFloat(commonsFile.width / commonsFile.height)
                }
            } else {
                imageView?.image = nil
            }
        }
    }

    // MARK: Subviews

    @IBOutlet private var imageView: NSImageView?

    @IBOutlet private var imageViewWidth: NSLayoutConstraint?
    @IBOutlet private var imageViewHeight: NSLayoutConstraint?

}
