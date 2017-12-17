//
//  RootViewModel.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 17/12/2017.
//

import Foundation

struct RootViewModel {

    let title: String

}

extension RootViewModel {

    init(_ object: Any) {
        self.init(title: "\(type(of: object)) - \(object)")
    }

}

extension RootViewModel: DetailViewModel { }
