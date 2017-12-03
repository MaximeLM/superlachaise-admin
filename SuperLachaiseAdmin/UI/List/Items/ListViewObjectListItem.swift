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

protocol ListViewObjectListItemType: ListViewItem {

    var filter: String { get set }

}

class ListViewObjectListItem<Element: Object & RealmListable>: NSObject, ListViewObjectListItemType {

    let baseText: String

    var filter: String {
        get {
            return _filter.value
        }
        set {
            _filter.value = newValue
        }
    }

    init(baseText: String, realm: Realm, filter: String) {
        self.baseText = baseText
        self.identifier = "ListViewObjectListItem.\(Element.self)"
        self._filter = Variable(filter)

        super.init()
        _filter.asObservable()
            .flatMapLatest { Observable.array(from: Element.list(filter: $0)(realm)) }
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

    // MARK: Private

    private let disposeBag = DisposeBag()

    private let _filter: Variable<String>

    private let _children = Variable<[ListViewItem]>([])

}
