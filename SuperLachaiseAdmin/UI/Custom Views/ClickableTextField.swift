//
//  ClickableTextField.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 20/12/2017.
//

import Cocoa

class ClickableTextField: NSTextField {

    override func resetCursorRects() {
        addCursorRect(bounds, cursor: .pointingHand)
    }

}
