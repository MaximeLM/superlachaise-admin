//
//  MainWindowController+Navigation.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 20/12/2017.
//

import Cocoa

extension MainWindowController {

    @IBAction func navigationSegmentControlAction(_ sender: NSSegmentedControl) {
        if sender.selectedSegment == 0 {
            navigateBack()
        } else {
            navigateForward()
        }
    }

    func selectNewModel(_ model: MainWindowModel) {
        modelHistory.removeLast(modelHistory.count - modelHistoryIndex - 1)
        modelHistory.append(model)
        modelHistoryIndex += 1
        updateNavigation()
    }

    func navigateBack() {
        guard canNavigateBack else {
            return
        }
        modelHistoryIndex -= 1
        updateNavigation()
    }

    func navigateForward() {
        guard canNavigateForward else {
            return
        }
        modelHistoryIndex += 1
        updateNavigation()
    }

    private var canNavigateBack: Bool {
        return modelHistoryIndex > 0
    }

    private var canNavigateForward: Bool {
        return modelHistoryIndex + 1 < modelHistory.count
    }

    private func updateNavigation() {
        self.model.value = modelHistory[modelHistoryIndex]
        navigationSegmentedControl?.setEnabled(canNavigateBack, forSegment: 0)
        navigationSegmentedControl?.setEnabled(canNavigateForward, forSegment: 1)
    }

}
