//
//  MainWindowModel.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 20/12/2017.
//

import Foundation
import RealmSwift
import RxRealm
import RxSwift

typealias MainWindowModel = Object & MainWindowModelType

protocol MainWindowModelType: RealmIdentifiable {

    var mainWindowTitle: String { get }

    func detailViewModel() -> DetailViewModel

}

extension MainWindowModelType {

    var mainWindowTitle: String {
        return "\(type(of: self)): \(self)"
    }

    /**
     Publish the object each time the realm is saved, starting synchronously
    */
    func asObservable(realm: Realm) -> Observable<Self> {
        let realmObservable = Observable<(Realm, Realm.Notification)>.from(realm: realm)
        return realmObservable
            .map { _ in }
            .startWith(())
            .map { _ in self }
    }

}
