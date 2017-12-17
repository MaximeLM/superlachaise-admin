//
//  OpenStreetMapElement+RootViewSource.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 17/12/2017.
//

import Foundation
import RxRealm
import RxSwift

extension OpenStreetMapElement: RootViewSource {

    func rootViewModel() -> RootViewModel {
        return RootViewModel(self)
    }

}
