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

    // MARK: Properties

    static var isFirstWindow = true

    var retainedSelf: MainWindowController?

    let disposeBag = DisposeBag()

    var modelHistory: [MainWindowModel] = []

    var modelHistoryIndex: Int = -1

    // MARK: Subviews

    @IBOutlet weak var titleLabel: NSTextField?

    @IBOutlet weak var navigationSegmentedControl: NSSegmentedControl?

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

        // Keep the instance alive until the window closes
        retainedSelf = self

        window?.titleVisibility = .hidden

        let model = self.model

        // Republish the model each time the realm is saved
        Observable<(Realm, Realm.Notification)>.from(realm: realmContext.viewRealm)
            .map { _ in model.value }
            .bind(to: model)
            .disposed(by: disposeBag)

        // Update title from model
        model.asObservable()
            .map { $0?.mainWindowTitle ?? "SuperLachaiseAdmin" }
            .subscribe(onNext: { [weak self] title in
                self?.window?.title = title
                self?.titleLabel?.stringValue = title
            })
            .disposed(by: disposeBag)

        // Subscribe to child view controller selections
        rootViewController?.didSelectModel
            .subscribe(onNext: { [weak self] model in
                self?.selectNewModel(model)
            })
            .disposed(by: disposeBag)

        // Update root view controller with model
        if let rootViewController = rootViewController {
            model.asObservable()
                .bind(to: rootViewController.model)
                .disposed(by: disposeBag)
        }

    }

    func windowWillClose(_ notification: Notification) {
        retainedSelf = nil
    }

}
