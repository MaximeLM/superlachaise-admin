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
        return []
    }

}
