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

    @IBAction func doubleClickAction(_ outlineView: NSOutlineView) {
        let item = outlineView.item(atRow: outlineView.clickedRow)
        guard outlineView.isExpandable(item) else {
            return
        }

        if outlineView.isItemExpanded(item) {
            outlineView.collapseItem(item)
        } else {
            outlineView.expandItem(item)
        }
    }

}
