//
//  ListViewController+Actions.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 03/12/2017.
//

import Cocoa

extension ListViewController {

    @IBAction func doubleClickItem(_ outlineView: NSOutlineView) {
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
