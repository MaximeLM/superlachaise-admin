//
//  RootViewSource.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 17/12/2017.
//

import Foundation
import RealmSwift
import RxCocoa
import RxRealm
import RxSwift

protocol RootViewSource {

    func rootViewModel() -> RootViewModel

}

extension RootViewSource {

    func asObservable(realm: Realm) -> Observable<RootViewModel?> {
        let realmObservable = Observable<(Realm, Realm.Notification)>.from(realm: realm)
            .map { _ in }
        return Observable.just(()).concat(realmObservable)
            .map { _ in self.rootViewModel() }
    }

    func asDriver(realm: Realm) -> Driver<RootViewModel?> {
        return asObservable(realm: realm)
            .asDriver(onErrorJustReturn: nil)
    }

}
