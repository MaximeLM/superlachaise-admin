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

    var commonsFile: CoreDataCommonsFile? {
        didSet {
            if let commonsFile = commonsFile {
                imageView?.sd_setImage(with: commonsFile.thumbnailURL(height: 600), completed: nil)
                if let imageViewWidth = imageViewWidth, let imageViewHeight = imageViewHeight {
                    imageViewWidth.constant = imageViewHeight.constant * CGFloat(commonsFile.ratio)
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
