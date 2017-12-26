//
//  DetailViewController.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 16/12/2017.
//

import Cocoa
import RxSwift

protocol DetailViewControllerType: NSObjectProtocol {

    var model: MainWindowModel? { get set }

}

final class DetailViewController: NSViewController, DetailViewControllerType {

    // MARK: Dependencies

    lazy var realmContext = AppContainer.realmContext

    // MARK: Model

    var model: MainWindowModel? {
        didSet {
            // Scroll to top on model change
            if let documentView = scrollView?.documentView {
                documentView.scroll(NSPoint(x: 0, y: documentView.bounds.height))
            }
            updateViewsFromModel()
        }
    }

    func updateViewsFromModel() {
        let views = model?.detailViewModel().views() ?? []
        stackView?.setViews(views, in: .top)
    }

    // MARK: Properties

    let disposeBag = DisposeBag()

    // MARK: Subviews

    @IBOutlet var scrollView: NSScrollView?

    @IBOutlet var stackView: NSStackView?

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        updateViewsFromModel()
        realmContext.viewRealmSaveNotification
            .subscribe(onNext: { [weak self] _ in
                self?.updateViewsFromModel()
            })
            .disposed(by: disposeBag)

    }

}
