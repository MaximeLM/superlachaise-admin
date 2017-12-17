//
//  RootViewController.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 29/11/2017.
//

import Cocoa
import RxCocoa
import RxSwift

final class RootViewController: NSSplitViewController {

    // MARK: Dependencies

    lazy var realmContext = AppContainer.realmContext

    lazy var taskController = AppContainer.taskController

    // MARK: Subviews

    var listViewController: ListViewControllerType?

    var detailViewController: DetailViewControllerType?

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        listViewController = childViewControllers.flatMap { $0 as? ListViewControllerType }.first
        detailViewController = childViewControllers.flatMap { $0 as? DetailViewControllerType }.first

        listViewController?.didSelectRootViewSource = { [weak self] source in
            self?.source.value = source
        }

        let realm = realmContext.viewRealm
        source.asObservable()
            .flatMapLatest { source -> Driver<RootViewModel?> in
                source?.asDriver(realm: realm) ?? Driver.just(nil)
            }
            .subscribe(onNext: { [weak self] model in
                self?.view.window?.title = model?.title ?? "SuperLachaiseAdmin"
                self?.detailViewController?.model = model
            })
            .disposed(by: disposeBag)

        source.asObservable()
            .subscribe(onNext: { [weak self] _ in
                self?.detailViewController?.didSwitchSource()
            })
            .disposed(by: disposeBag)

    }

    // MARK: Model

    private let disposeBag = DisposeBag()

    let source = Variable<RootViewSource?>(nil)

}
