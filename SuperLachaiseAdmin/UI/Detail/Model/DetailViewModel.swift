//
//  DetailViewModel.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 17/12/2017.
//

import Cocoa

protocol DetailViewModel {

    var title: String { get }

}

extension DetailViewModel {

    func detailSubviews() -> [NSView] {
        var subviews: [NSView?] = []

        // Title
        let titleView = DetailTitleView.instantiate()
        titleView?.title = title
        subviews.append(titleView)

        return subviews.flatMap { $0 }
    }

}
