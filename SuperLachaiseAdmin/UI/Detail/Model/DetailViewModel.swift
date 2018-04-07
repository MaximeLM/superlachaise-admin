//
//  DetailViewModel.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 17/12/2017.
//

import Cocoa

struct DetailViewModel {

    let title: String

    let url: URL?

    let items: [[DetailViewItem]]

}

extension DetailViewModel {

    init(_ object: Any, items: [[DetailViewItem]]) {
        self.title = "\(type(of: object)): \(object)"
        if let object = object as? OpenableInBrowser {
            self.url = object.externalURL
        } else {
            self.url = nil
        }
        self.items = items
    }

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

        return items.compactMap { $0.view }
    }

}
