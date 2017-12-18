//
//  DetailViewSource.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 18/12/2017.
//

import Foundation
import RealmSwift
import RxCocoa
import RxSwift

protocol DetailViewSource: RealmIdentifiable {

    func detailViewModel() -> DetailViewModel

}

extension DetailViewSource {

    func asObservable(realm: Realm) -> Observable<DetailViewModel?> {
        let realmObservable = Observable<(Realm, Realm.Notification)>.from(realm: realm)
            .map { _ in }
        return Observable.just(()).concat(realmObservable)
            .map { _ in self.detailViewModel() }
    }

}
