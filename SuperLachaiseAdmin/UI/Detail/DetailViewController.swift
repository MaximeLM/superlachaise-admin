//
//  DetailViewController.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 16/12/2017.
//

import Cocoa
import RxCocoa
import RxSwift

protocol DetailViewControllerType: NSObjectProtocol {

    var source: DetailViewSource? { get set }

    var didChangeTitle: ((String?) -> Void)? { get set }

}

final class DetailViewController: NSViewController, DetailViewControllerType {

    // MARK: Dependencies

    lazy var realmContext = AppContainer.realmContext

    // MARK: Model

    var source: DetailViewSource? {
        get {
            return _source.value
        }
        set {
            _source.value = newValue
        }
    }

    private let _source = Variable<DetailViewSource?>(nil)

    // MARK: Subviews

    @IBOutlet weak var  scrollView: NSScrollView?

    @IBOutlet weak var  stackView: NSStackView?

    // MARK: Properties

    var didChangeTitle: ((String?) -> Void)?

    private let disposeBag = DisposeBag()

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Reload stack view when the source is changed or the realm is saved
        let realm = realmContext.viewRealm
        _source.asObservable()
            .flatMapLatest { source in
                source?.asObservable(realm: realm).catchErrorJustReturn(nil) ?? Observable.just(nil)
            }
            .subscribe(onNext: { [weak self] model in
                self?.didChangeTitle?(model?.title)
                self?.stackView?.setViews(model?.views() ?? [], in: .top)
            })
            .disposed(by: disposeBag)

        // Scroll to top on source change
        _source.asObservable()
            .subscribe(onNext: { [weak self] _ in
                if let documentView = self?.scrollView?.documentView {
                    documentView.scroll(NSPoint(x: 0, y: documentView.bounds.height))
                }
            })
            .disposed(by: disposeBag)

    }

}
