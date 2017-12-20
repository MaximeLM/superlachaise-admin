//
//  RootViewController.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 29/11/2017.
//

import Cocoa
import RealmSwift
import RxSwift

final class RootViewController: NSSplitViewController {

    // MARK: Dependencies

    lazy var taskController = AppContainer.taskController

    // MARK: Subviews

    @IBOutlet weak var listSplitViewItem: NSSplitViewItem?

    @IBOutlet weak var detailSplitViewItem: NSSplitViewItem?

    // MARK: Properties

    private let disposeBag = DisposeBag()

    // MARK: Other views

    var window: NSWindow? {
        return view.window
    }

    var windowController: MainWindowController? {
        return window?.windowController as? MainWindowController
    }

    var navigationSegmentedControl: NSSegmentedControl? {
        return windowController?.navigationSegmentedControl
    }

    var titleLabel: NSTextField? {
        return windowController?.titleLabel
    }

    var listViewController: ListViewControllerType? {
        return listSplitViewItem?.viewController as? ListViewControllerType
    }

    var detailViewController: DetailViewControllerType? {
        return detailSplitViewItem?.viewController as? DetailViewControllerType
    }

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        listViewController?.selectedObject
            .subscribe(onNext: { [weak self] object in
                guard let source = object as? DetailViewSource else {
                    return
                }
                guard source.identifier != self?.detailViewController?.source.value?.identifier else {
                    return
                }
                self?.selectNewSource(source)
            })
            .disposed(by: disposeBag)

        detailViewController?.model
            .subscribe(onNext: { [weak self] model in
                let newTitle = model?.title ?? "SuperLachaiseAdmin"
                self?.titleLabel?.stringValue = newTitle
                self?.window?.title = newTitle
            })
            .disposed(by: disposeBag)

    }

    // MARK: Source

    private var sourceHistory: [DetailViewSource] = []

    private var sourceHistoryIndex: Int = -1

    private var canGoBackInSources: Bool {
        return sourceHistoryIndex > 0
    }

    private var canGoForwardInSources: Bool {
        return sourceHistoryIndex + 1 < sourceHistory.count
    }

    func selectNewSource(_ source: DetailViewSource) {
        _ = sourceHistory.dropLast(sourceHistory.count - sourceHistoryIndex)
        sourceHistory.append(source)
        sourceHistoryIndex += 1
        detailViewController?.source.value = source
        updateNavigationSegmentedControl()
    }

    func goBackInSources() {
        guard canGoBackInSources else {
            return
        }
        sourceHistoryIndex -= 1
        detailViewController?.source.value = sourceHistory[sourceHistoryIndex]
        updateNavigationSegmentedControl()
    }

    func goForwardInSources() {
        guard canGoForwardInSources else {
            return
        }
        sourceHistoryIndex += 1
        detailViewController?.source.value = sourceHistory[sourceHistoryIndex]
        updateNavigationSegmentedControl()
    }

    private func updateNavigationSegmentedControl() {
        navigationSegmentedControl?.setEnabled(canGoBackInSources, forSegment: 0)
        navigationSegmentedControl?.setEnabled(canGoForwardInSources, forSegment: 1)

    }

}
