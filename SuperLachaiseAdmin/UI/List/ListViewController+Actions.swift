//
//  ListViewController+Actions.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 03/12/2017.
//

import Cocoa

extension ListViewController {

    @IBAction func doubleClickAction(_ outlineView: NSOutlineView) {
        // Cancel selection
        pendingSelectedModel = nil

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
