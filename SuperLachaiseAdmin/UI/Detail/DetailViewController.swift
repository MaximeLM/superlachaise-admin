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

    var source: Variable<DetailViewSource?> { get }

    var model: Observable<DetailViewModel?> { get }

}

final class DetailViewController: NSViewController, DetailViewControllerType {

    // MARK: Dependencies

    lazy var realmContext = AppContainer.realmContext

    // MARK: Model

    let source = Variable<DetailViewSource?>(nil)

    var model: Observable<DetailViewModel?> {
        return _model.asObservable()
    }

    private let _model = Variable<DetailViewModel?>(nil)

    // MARK: Subviews

    @IBOutlet weak var  scrollView: NSScrollView?

    @IBOutlet weak var  stackView: NSStackView?

    // MARK: Properties

    private let disposeBag = DisposeBag()

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Update model from source when the source is changed or the realm is saved
        let realm = realmContext.viewRealm
        source.asObservable()
            .flatMapLatest { source -> Observable<DetailViewModel?> in
                let realmObservable = Observable<(Realm, Realm.Notification)>.from(realm: realm)
                return realmObservable
                    .map { _ in }
                    .startWith(())
                    .map { _ in source?.detailViewModel() }
            }
            .bind(to: _model)
            .disposed(by: disposeBag)

        // Bind the model to the stack view
        _model.asObservable()
            .subscribe(onNext: { [weak self] model in
                self?.stackView?.setViews(model?.views() ?? [], in: .top)
            })
            .disposed(by: disposeBag)

        // Scroll to top on source change
        source.asObservable()
            .subscribe(onNext: { [weak self] _ in
                if let documentView = self?.scrollView?.documentView {
                    documentView.scroll(NSPoint(x: 0, y: documentView.bounds.height))
                }
            })
            .disposed(by: disposeBag)

    }

}
