//
//  MainWindowController+Search.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 22/12/2017.
//

import Cocoa

extension MainWindowController {

    @IBAction func find(_ sender: Any?) {
        window?.makeFirstResponder(searchField)
    }

    @IBAction func searchAction(_ searchField: NSSearchField) {
        rootViewController?.searchValue = searchField.stringValue
    }

}
