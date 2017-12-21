//
//  RootViewController.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 29/11/2017.
//

import Cocoa
import RealmSwift
import RxSwift

protocol RootViewControllerType: NSObjectProtocol {

    var didSelectModel: Observable<MainWindowModel> { get }

    var model: Variable<MainWindowModel?> { get }

    var refreshModel: Variable<MainWindowModel?> { get }

}

final class RootViewController: NSSplitViewController, RootViewControllerType {

    // MARK: Dependencies

    lazy var taskController = AppContainer.taskController

    // MARK: Model

    let model = Variable<MainWindowModel?>(nil)

    // MARK: Subviews

    @IBOutlet var listSplitViewItem: NSSplitViewItem?

    @IBOutlet var detailSplitViewItem: NSSplitViewItem?

    // MARK: Properties

    var didSelectModel: Observable<MainWindowModel> {
        return _didSelectModel.asObservable()
    }

    private let _didSelectModel = PublishSubject<MainWindowModel>()

    let refreshModel = Variable<MainWindowModel?>(nil)

    let disposeBag = DisposeBag()

    // MARK: Child view controllers

    var listViewController: ListViewControllerType? {
        return listSplitViewItem?.viewController as? ListViewControllerType
    }

    var detailViewController: DetailViewControllerType? {
        return detailSplitViewItem?.viewController as? DetailViewControllerType
    }

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        let didSelectModel = _didSelectModel
        listViewController?.didSelectModel
            .subscribe(onNext: { model in
                didSelectModel.onNext(model)
            })
            .disposed(by: disposeBag)

        if let detailViewController = detailViewController {

            model.asObservable()
                .bind(to: detailViewController.model)
                .disposed(by: disposeBag)

            refreshModel.asObservable()
                .bind(to: detailViewController.refreshModel)
                .disposed(by: disposeBag)

        }

    }

}
