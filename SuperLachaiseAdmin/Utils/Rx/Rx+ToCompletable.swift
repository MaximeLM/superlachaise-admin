//
//  Rx+ToCompletable.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 14/12/2017.
//

import Foundation
import RxSwift

extension ObservableConvertibleType {

    func toCompletable() -> Completable {
        return self.asObservable().ignoreElements()
    }

}
