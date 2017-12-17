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

    var items: [[DetailViewItem]] { get }

}

extension DetailViewModel {

    func views() -> [NSView] {
        var items: [DetailViewItem] = []

        // Title
        items.append(DetailViewTitleItem(title: title))

        // URL
        if let url = url {
            items.append(DetailViewURLItem(url: url))
        }

        items.append(DetailViewSeparatorItem())

        // Other items
        items.append(contentsOf: self.items.joined(separator: [DetailViewSeparatorItem()]))

        return items.flatMap { $0.view }
    }

}
