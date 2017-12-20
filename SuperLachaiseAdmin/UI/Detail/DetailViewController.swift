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

}

final class DetailViewController: NSViewController, DetailViewControllerType {

    // MARK: Model

    let model = Variable<MainWindowModel?>(nil)

    // MARK: Subviews

    @IBOutlet weak var  scrollView: NSScrollView?

    @IBOutlet weak var  stackView: NSStackView?

    // MARK: Properties

    private let disposeBag = DisposeBag()

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Bind the model to the stack view
        model.asObservable()
            .map { $0?.detailViewModel().views() ?? [] }
            .subscribe(onNext: { [weak self] views in
                self?.stackView?.setViews(views, in: .top)
            })
            .disposed(by: disposeBag)

        // Scroll to top on model identity change
        model.asObservable()
            .subscribe(onNext: { [weak self] _ in
                if let documentView = self?.scrollView?.documentView {
                    documentView.scroll(NSPoint(x: 0, y: documentView.bounds.height))
                }
            })
            .disposed(by: disposeBag)

    }

}
