//
//  Task.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 28/11/2017.
//

import Foundation
import RxSwift

protocol Task: CustomStringConvertible {

    func asSingle() -> Single<Void>

}

extension Task {

    var description: String {
        return "\(type(of: self))"
    }

}
