//
//  NSTextField+URL.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 17/12/2017.
//

import Cocoa

extension NSTextField {

    var htmlStringValue: String {
        get {
            return attributedStringValue.string
        }
        set {
            let fontSize = self.font?.pointSize ?? NSFont.systemFontSize
            let style = "font-family:'Verdana'; font-size:\(fontSize)px;"
            let html = "<span style=\"\(style)\">\(newValue)</span>"
            guard let data = html.data(using: .utf8) else {
                assertionFailure()
                return
            }
            let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
                .characterEncoding: NSNumber(value: String.Encoding.utf8.rawValue),
            ]
            guard let attributedString = NSAttributedString(html: data,
                                                            options: options,
                                                            documentAttributes: nil) else {
                assertionFailure()
                return
            }
            attributedStringValue = attributedString
        }
    }

}
