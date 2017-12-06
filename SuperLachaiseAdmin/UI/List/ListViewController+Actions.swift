//
//  ListViewController+Actions.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 03/12/2017.
//

import Cocoa

extension ListViewController {

    // MARK: Menu

    override func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        guard let tag = ListViewMenuItemTag(rawValue: menuItem.tag) else {
            return false
        }
        guard let outlineView = outlineView else {
            return false
        }
        let item = outlineView.item(atRow: outlineView.clickedRow)
        switch tag {
        case .openInBrowser:
            guard let item = item as? ListViewObjectItem else {
                return false
            }
            return item.object is RealmOpenableInBrowser
        case .syncOpenStreetMapElement:
            guard let item = item as? ListViewObjectItem else {
                return false
            }
            return item.object is SuperLachaisePOI
        }
    }

    // MARK: Actions

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

    @IBAction func searchAction(_ searchField: NSSearchField) {
        rootItem?.filter = searchField.stringValue
    }

    @IBAction func openInBrowser(_ sender: Any?) {
        guard let outlineView = outlineView,
            let item = outlineView.item(atRow: outlineView.clickedRow) as? ListViewObjectItem,
            let object = item.object as? RealmOpenableInBrowser else {
            return
        }
        guard let externalURL = object.externalURL else {
            Logger.error("Object \(object) has no external URL")
            return
        }
        NSWorkspace.shared.open(externalURL)
    }

    @IBAction func syncOpenStreetMapElement(_ sender: Any?) {

    }

}

private enum ListViewMenuItemTag: Int {

    case openInBrowser = 0

    case syncOpenStreetMapElement = 10

}
