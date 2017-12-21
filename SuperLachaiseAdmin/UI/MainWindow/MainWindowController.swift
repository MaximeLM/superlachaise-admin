//
//  MainWindowController.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 02/12/2017.
//

import Cocoa
import RealmSwift
import RxRealm
import RxSwift

final class MainWindowController: NSWindowController, NSWindowDelegate {

    // MARK: Dependencies

    lazy var realmContext = AppContainer.realmContext

    lazy var taskController = AppContainer.taskController

    // MARK: Model

    let model = Variable<MainWindowModel?>(nil)

    let refreshModel = Variable<MainWindowModel?>(nil)

    // MARK: Properties

    static var isFirstWindow = true

    var disposeBag: DisposeBag?

    var modelHistory: [MainWindowModel] = []

    var modelHistoryIndex: Int = -1

    // MARK: Subviews

    @IBOutlet var titleLabel: NSTextField?

    @IBOutlet var navigationSegmentedControl: NSSegmentedControl?

    @IBOutlet var syncButton: NSButton?

    // MARK: Child view controllers

    var rootViewController: RootViewControllerType? {
        return window?.contentViewController as? RootViewControllerType
    }

    // MARK: Lifecycle

    override func windowDidLoad() {
        super.windowDidLoad()

        if MainWindowController.isFirstWindow {
            MainWindowController.isFirstWindow = false
            let autosaveName = NSWindow.FrameAutosaveName(rawValue: "MainWindow")
            window?.setFrameUsingName(autosaveName)
            windowFrameAutosaveName = autosaveName
        }

        window?.titleVisibility = .hidden
        syncButton?.toolTip = "Sync current object"

        configureObservables()
    }

    private func configureObservables() {
        let disposeBag = DisposeBag()

        // Publish the model each time the model is changed or the realm is saved
        let realmObservable = Observable<(Realm, Realm.Notification)>.from(realm: realmContext.viewRealm)
        Observable.merge(model.asObservable(), realmObservable.map { _ in self.model.value })
            .bind(to: refreshModel)
            .disposed(by: disposeBag)

        // Update views from model
        refreshModel.asObservable()
            .map { $0?.mainWindowTitle ?? "SuperLachaiseAdmin" }
            .subscribe(onNext: { title in
                self.window?.title = title
                self.titleLabel?.stringValue = title
            })
            .disposed(by: disposeBag)
        if let syncButton = syncButton {
            model.asObservable()
                .map { $0 is Syncable }
                .bind(to: syncButton.rx.isEnabled)
                .disposed(by: disposeBag)
        }

        // Subscribe to child view controller selections
        rootViewController?.didSingleClickModel?
            .distinctUntilChanged { $0 as Object }
            .subscribe(onNext: { model in
                self.selectNewModel(model)
            })
            .disposed(by: disposeBag)
        rootViewController?.didDoubleClickModel?
            .subscribe(onNext: { model in
                self.newTab(self.instantiate(model: model))
            })
            .disposed(by: disposeBag)

        // Subscribe child view controller to model
        model.asObservable()
            .subscribe(onNext: { model in
                self.rootViewController?.model = model
            })
            .disposed(by: disposeBag)
        refreshModel.asObservable()
            .subscribe(onNext: { model in
                self.rootViewController?.refreshModel = model
            })
            .disposed(by: disposeBag)

        self.disposeBag = disposeBag
    }

    func windowWillClose(_ notification: Notification) {
        disposeBag = nil
    }

}
