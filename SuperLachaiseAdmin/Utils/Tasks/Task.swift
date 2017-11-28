//
//  Task.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 28/11/2017.
//

import Foundation
import RxSwift

protocol Task: CustomStringConvertible {

    func asCompletable() -> Completable

}

extension Task {

    var description: String {
        return String(describing: type(of: self))
    }

    func asOperation() -> Operation {
        return RxOperation {
            self.asCompletable()
                .do(onSubscribe: { Logger.info("\(self) started") })
                .subscribe(onCompleted: { Logger.success("\(self) succeeded") },
                           onError: { Logger.error("\(self) failed: \($0)") })
        }
    }

}
