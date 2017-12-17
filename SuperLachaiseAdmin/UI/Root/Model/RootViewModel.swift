//
//  RootViewModel.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 17/12/2017.
//

import Cocoa

struct RootViewModel {

    let title: String

    let url: URL?

    let subviews: [[NSView?]]

}

extension RootViewModel {

    init(_ object: Any, subviews: [[NSView?]]) {
        self.title = "\(type(of: object)): \(object)"
        if let object = object as? RealmOpenableInBrowser {
            self.url = object.externalURL
        } else {
            self.url = nil
        }
        self.subviews = subviews
    }

}

extension RootViewModel: DetailViewModel { }
