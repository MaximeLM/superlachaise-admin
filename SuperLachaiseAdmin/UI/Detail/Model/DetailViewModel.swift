//
//  DetailViewModel.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 17/12/2017.
//

import Cocoa

protocol DetailViewModel {

    var title: String { get }

    var url: URL? { get }

}

extension DetailViewModel {

    func detailSubviews() -> [NSView] {
        var subviews: [NSView?] = []

        // Title
        subviews.append(DetailViewTitleView.instantiate(title: title))

        // URL
        if let url = url {
            subviews.append(DetailViewURLView.instantiate(url: url))
        }

        return subviews.flatMap { $0 }
    }

}
