//
//  NSTextField+URL.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 17/12/2017.
//

import Cocoa

class ClickableTextField: NSTextField {

    override func resetCursorRects() {
        addCursorRect(bounds, cursor: .pointingHand)
    }

}

extension NSTextField {

    var htmlStringValue: String {
        get {
            return attributedStringValue.string
        }
        set {
            let font = self.font ?? NSFont.systemFont(ofSize: NSFont.systemFontSize)
            let style = "font-family:'\(font.fontName)'; font-size:\(font.pointSize)px;"
            let html = "<span style=\"\(style)\">\(newValue)</span>"
            guard let data = html.data(using: .utf8) else {
                assertionFailure()
                return
            }
            guard let attributedString = NSAttributedString(html: data, options: [:], documentAttributes: nil) else {
                assertionFailure()
                return
            }
            attributedStringValue = attributedString
        }
    }

}
