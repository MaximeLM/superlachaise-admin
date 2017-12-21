//
//  ListViewController+Actions.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 03/12/2017.
//

import Cocoa

extension ListViewController {

    // MARK: Main menu

    @IBAction func find(_ sender: Any?) {
        view.window?.makeFirstResponder(searchField)
    }

    // MARK: Subviews

    @IBAction func searchAction(_ searchField: NSSearchField) {
        rootItem?.filter = searchField.stringValue
    }

    @IBAction func outlineViewSingleClickAction(_ outlineView: NSOutlineView) {
        let item = outlineView.item(atRow: outlineView.clickedRow)

        // Delay event to prevent collision with double click
        shouldPerformSingleClickAction = true
        let deadline: DispatchTime = .now() + .milliseconds(250)
        DispatchQueue.main.asyncAfter(deadline: deadline) {
            guard self.shouldPerformSingleClickAction else {
                return
            }
            self.shouldPerformSingleClickAction = false
            self.doOutlineViewSingleClickAction(item: item)
        }
    }

    private func doOutlineViewSingleClickAction(item: Any?) {
        if let item = item as? ListViewObjectItem {
            didSingleClickModelSubject.onNext(item.object)
        }
    }

    @IBAction func outlineViewDoubleClickAction(_ outlineView: NSOutlineView) {
        // Cancel single click
        shouldPerformSingleClickAction = false

        let item = outlineView.item(atRow: outlineView.clickedRow)
        if let item = item as? ListViewObjectItem {
            didDoubleClickModelSubject.onNext(item.object)
        } else if outlineView.isExpandable(item) {
            if outlineView.isItemExpanded(item) {
                outlineView.collapseItem(item)
            } else {
                outlineView.expandItem(item)
            }
        }
    }

}
