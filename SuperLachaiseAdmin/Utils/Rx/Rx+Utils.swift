//
//  Rx+Utils.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 29/11/2017.
//

import Foundation
import RxSwift

extension ObservableConvertibleType {

    func toCompletable() -> Completable {
        return asObservable().ignoreElements()
    }

}
