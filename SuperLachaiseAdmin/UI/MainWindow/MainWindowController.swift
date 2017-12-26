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

    @IBOutlet var searchField: NSSearchField?

    @IBOutlet var navigationSegmentedControl: NSSegmentedControl?

    @IBOutlet var titleLabel: NSTextField?

    @IBOutlet var taskCountButton: NSButton?

    @IBOutlet var cancelTaskButton: NSButton?

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
            let autosaveName = NSWindow.FrameAutosaveName("MainWindow")
            window?.setFrameUsingName(autosaveName)
            windowFrameAutosaveName = autosaveName
        }

        window?.titleVisibility = .hidden
        syncButton?.toolTip = "Sync current object"
        cancelTaskButton?.toolTip = "Cancel current task"

        let disposeBag = DisposeBag()
        bindModel(disposeBag: disposeBag)
        bindViews(disposeBag: disposeBag)
        self.disposeBag = disposeBag
    }

    private func bindModel(disposeBag: DisposeBag) {

        // Publish the model each time the model is changed or the realm is saved
        let realmObservable = Observable<(Realm, Realm.Notification)>.from(realm: realmContext.viewRealm)
        Observable.merge(model.asObservable(), realmObservable.map { _ in self.model.value })
            .bind(to: refreshModel)
            .disposed(by: disposeBag)

        // Subscribe to child view controller selections
        rootViewController?.didSelectModel?
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

    }

    private func bindViews(disposeBag: DisposeBag) {

        // Bind title
        refreshModel.asObservable()
            .map { $0?.mainWindowTitle ?? "SuperLachaiseAdmin" }
            .subscribe(onNext: { title in
                self.window?.title = title
                self.titleLabel?.stringValue = title
            })
            .disposed(by: disposeBag)

        // Bind sync button
        if let syncButton = syncButton {
            model.asObservable()
                .map { $0 is Syncable }
                .bind(to: syncButton.rx.isEnabled)
                .disposed(by: disposeBag)
        }

        // Bind task count button
        if let taskCountButton = taskCountButton {
            taskController.runningTasks.asObservable()
                .subscribe(onNext: { taskOperations in
                    taskCountButton.title = "\(taskOperations.count)"
                    if taskOperations.isEmpty {
                        taskCountButton.toolTip = "No running task"
                    } else {
                        taskCountButton.toolTip = taskOperations
                            .map { $0.description }
                            .joined(separator: "\n")
                    }
                })
                .disposed(by: disposeBag)
        }

        // Bind cancel task button
        if let cancelTaskButton = cancelTaskButton {
            taskController.runningTasks.asObservable()
                .map { !$0.isEmpty }
                .bind(to: cancelTaskButton.rx.isEnabled )
                .disposed(by: disposeBag)
        }

    }

    func windowWillClose(_ notification: Notification) {
        disposeBag = nil
    }

}
