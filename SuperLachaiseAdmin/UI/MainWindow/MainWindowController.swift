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

        let disposeBag = DisposeBag()

        // Publish the model each time the model is changed or the realm is saved
        let realmObservable = Observable<(Realm, Realm.Notification)>.from(realm: realmContext.viewRealm)
        Observable.merge(model.asObservable(), realmObservable.map { _ in self.model.value })
            .bind(to: refreshModel)
            .disposed(by: disposeBag)

        // Update title from model
        refreshModel.asObservable()
            .map { $0?.mainWindowTitle ?? "SuperLachaiseAdmin" }
            .subscribe(onNext: { title in
                self.window?.title = title
                self.titleLabel?.stringValue = title
            })
            .disposed(by: disposeBag)

        // Subscribe to child view controller selections
        rootViewController?.didSelectModel
            .distinctUntilChanged { $0 as Object }
            .subscribe(onNext: { model in
                self.selectNewModel(model)
            })
            .disposed(by: disposeBag)

        // Update root view controller with model
        if let rootViewController = rootViewController {

            model.asObservable()
                .bind(to: rootViewController.model)
                .disposed(by: disposeBag)

            refreshModel.asObservable()
                .bind(to: rootViewController.refreshModel)
                .disposed(by: disposeBag)

        }

        // Update sync button from model

        if let syncButton = syncButton {
            model.asObservable()
                .map { $0 is Syncable }
                .bind(to: syncButton.rx.isEnabled)
                .disposed(by: disposeBag)
        }

        self.disposeBag = disposeBag
    }

    func windowWillClose(_ notification: Notification) {
        disposeBag = nil
    }

}
