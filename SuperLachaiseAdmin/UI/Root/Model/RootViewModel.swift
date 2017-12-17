//
//  RootViewModel.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 17/12/2017.
//

import Cocoa

struct RootViewModel: DetailViewModel {

    let title: String

    let url: URL?

    let items: [[DetailViewItem]]

}

extension RootViewModel {

    init(_ object: Any, items: [[DetailViewItem]]) {
        self.title = "\(type(of: object)): \(object)"
        if let object = object as? RealmOpenableInBrowser {
            self.url = object.externalURL
        } else {
            self.url = nil
        }
        self.items = items
    }

}
