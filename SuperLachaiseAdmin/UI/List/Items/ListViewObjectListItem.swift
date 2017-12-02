//
//  ListViewObjectListItem.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 02/12/2017.
//

import Cocoa
import RealmSwift
import RxCocoa
import RxRealm
import RxSwift

class ListViewObjectListItem<Element: Object & RealmIdentifiable & RealmListable>: NSObject, ListViewItem {

    let baseText: String

    init(baseText: String, realm: Realm) {
        self.baseText = baseText
        self.identifier = "ListViewObjectListItem.\(Element.self)"

        super.init()
        Observable.array(from: Element.list()(realm))
            .catchErrorJustReturn([])
            .map { objects in
                objects.map { ListViewObjectItem(object: $0) }
            }
            .bind(to: _children)
            .disposed(by: disposeBag)
        _children
            .asObservable()
            .subscribe(onNext: { [weak self] _ in
                guard let `self` = self else {
                    return
                }
                self.reload?(self)
            })
            .disposed(by: disposeBag)
    }

    // MARK: ListViewItem

    let identifier: String

    var text: String {
        return "\(baseText) (\(children?.count ?? 0))"
    }

    var children: [ListViewItem]? {
        return _children.value
    }

    var reload: ((ListViewItem) -> Void)?

    // MARK: Observation

    private let disposeBag = DisposeBag()

    private let _children = Variable<[ListViewItem]>([])

}
