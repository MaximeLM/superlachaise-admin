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

extension PrimitiveSequenceType where TraitType == SingleTrait {

    static func create(_ task: @escaping () throws -> ElementType) -> Single<ElementType> {
        return Single.create { observer in
            do {
                let result = try task()
                observer(.success(result))
            } catch {
                observer(.error(error))
            }
            return Disposables.create()
        }
    }

}

extension PrimitiveSequenceType where TraitType == CompletableTrait, ElementType == Swift.Never {

    static func create(_ task: @escaping () throws -> Void) -> Completable {
        return Completable.create { observer in
            do {
                try task()
                observer(.completed)
            } catch {
                observer(.error(error))
            }
            return Disposables.create()
        }
    }

}
