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

}

final class RootViewController: NSSplitViewController, RootViewControllerType {

    // MARK: Dependencies

    lazy var taskController = AppContainer.taskController

    // MARK: Subviews

    @IBOutlet weak var listSplitViewItem: NSSplitViewItem?

    @IBOutlet weak var detailSplitViewItem: NSSplitViewItem?

    // MARK: Properties

    var didSelectModel: Observable<MainWindowModel> {
        return _didSelectModel.asObservable()
    }

    private let _didSelectModel = PublishSubject<MainWindowModel>()

    let model = Variable<MainWindowModel?>(nil)

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
        }

    }

}
