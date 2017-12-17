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

    var subviews: [[NSView?]] { get }

}

extension DetailViewModel {

    func views() -> [NSView] {
        var views: [NSView?] = []

        // Title
        views.append(DetailViewTitleView.instantiate(title: title))

        // URL
        if let url = url {
            views.append(DetailViewURLView.instantiate(url: url))
        }

        // Subviews
        views.append(contentsOf: subviews.joined())

        return views.flatMap { $0 }
    }

}
