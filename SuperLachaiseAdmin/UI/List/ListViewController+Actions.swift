//
//  ListViewController+Actions.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 03/12/2017.
//

import Cocoa

extension ListViewController {

    override func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        guard let action = menuItem.action else {
            return false
        }
        if menuItem.menu == contextualMenu {
            return validateContextualMenuItem(action: action)
        } else {
            return validateMainMenuItem(action: action)
        }
    }

    // MARK: Main menu

    private func validateMainMenuItem(action: Selector) -> Bool {
        switch action {
        case #selector(copy(_:)):
            guard let outlineView = outlineView else {
                return false
            }
            return outlineView.item(atRow: outlineView.selectedRow) is ListViewObjectItem
        case #selector(find(_:)):
            return true
        default:
            return false
        }
    }

    @IBAction func copy(_ sender: Any?) {
        guard let outlineView = outlineView,
            let item = outlineView.item(atRow: outlineView.selectedRow) as? ListViewObjectItem else {
            return
        }
        NSPasteboard.general.clearContents()
        NSPasteboard.general.writeObjects([item.text as NSString])
    }

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

    // MARK: Contextual menu

    private func validateContextualMenuItem(action: Selector) -> Bool {
        guard let outlineView = outlineView else {
            return false
        }
        let item = outlineView.item(atRow: outlineView.clickedRow)
        switch action {
        case #selector(openInBrowser(_:)):
            guard let item = item as? ListViewObjectItem else {
                return false
            }
            return item.object is RealmOpenableInBrowser
        case #selector(syncSelectedOpenStreetMapElement(_:)):
            guard let item = item as? ListViewObjectItem else {
                return false
            }
            return item.object is SuperLachaisePOI || item.object is OpenStreetMapElement
        case #selector(syncSelectedWikidataEntries(_:)):
            guard let item = item as? ListViewObjectItem else {
                return false
            }
            return item.object is SuperLachaisePOI || item.object is WikidataEntry
        default:
            return false
        }
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

    @IBAction func syncSelectedOpenStreetMapElement(_ sender: Any?) {
        guard let outlineView = outlineView,
            let item = outlineView.item(atRow: outlineView.clickedRow) as? ListViewObjectItem else {
                return
        }
        let openStreetMapElement: OpenStreetMapElement
        if let superLachaisePOI = item.object as? SuperLachaisePOI {
            guard let _openStreetMapElement = superLachaisePOI.openStreetMapElement else {
                Logger.error("\(SuperLachaisePOI.self) \(superLachaisePOI) has no OpenStreetMap element")
                return
            }
            openStreetMapElement = _openStreetMapElement
        } else if let _openStreetMapElement = item.object as? OpenStreetMapElement {
            openStreetMapElement = _openStreetMapElement
        } else {
            return
        }
        guard let openStreetMapId = openStreetMapElement.openStreetMapId else {
            Logger.error("\(OpenStreetMapElement.self) \(openStreetMapElement) has no OpenStreetMap id")
            return
        }
        taskController.syncOpenStreetMapElement([openStreetMapId])
    }

    @IBAction func syncSelectedWikidataEntries(_ sender: Any?) {
        guard let outlineView = outlineView,
            let item = outlineView.item(atRow: outlineView.clickedRow) as? ListViewObjectItem else {
                return
        }
        let wikidataId: String
        if let superLachaisePOI = item.object as? SuperLachaisePOI {
            wikidataId = superLachaisePOI.wikidataId
        } else if let wikidataEntry = item.object as? WikidataEntry {
            wikidataId = wikidataEntry.wikidataId
        } else {
            return
        }
        taskController.syncWikidataEntries(ids: [wikidataId])
    }

}
