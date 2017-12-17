//
//  RootViewModel.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 17/12/2017.
//

import Foundation

struct RootViewModel {

    let title: String

    let url: URL?

}

extension RootViewModel {

    init(_ object: Any) {
        title = "\(type(of: object)) - \(object)"
        if let object = object as? RealmOpenableInBrowser {
            url = object.externalURL
        } else {
            url = nil
        }
    }

}

extension RootViewModel: DetailViewModel { }
