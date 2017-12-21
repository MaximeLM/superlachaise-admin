//
//  DetailViewController.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 16/12/2017.
//

import Cocoa
import RealmSwift
import RxCocoa
import RxSwift

protocol DetailViewControllerType: NSObjectProtocol {

    var model: Variable<MainWindowModel?> { get }

    var refreshModel: Variable<MainWindowModel?> { get }

}

final class DetailViewController: NSViewController, DetailViewControllerType {

    // MARK: Model

    let model = Variable<MainWindowModel?>(nil)

    // MARK: Subviews

    @IBOutlet var scrollView: NSScrollView?

    @IBOutlet var stackView: NSStackView?

    // MARK: Properties

    let refreshModel = Variable<MainWindowModel?>(nil)

    private let disposeBag = DisposeBag()

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Bind the model to the stack view
        if let stackView = stackView {
            refreshModel.asObservable()
                .map { $0?.detailViewModel().views() ?? [] }
                .subscribe(onNext: { views in
                    stackView.setViews(views, in: .top)
                })
                .disposed(by: disposeBag)
        }

        // Scroll to top on model change
        if let documentView = scrollView?.documentView {

            model.asObservable()
                .subscribe(onNext: { _ in
                    documentView.scroll(NSPoint(x: 0, y: documentView.bounds.height))
                })
                .disposed(by: disposeBag)

        }

    }

}
