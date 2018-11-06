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
            let font = self.font ?? NSFont.systemFont(ofSize: NSFont.systemFontSize)
            let color = (self.textColor ?? .labelColor).usingColorSpaceName(.deviceRGB)
                ?? NSColor(calibratedRed: 0, green: 0, blue: 0, alpha: 1)
            var red: CGFloat = 0
            var green: CGFloat = 0
            var blue: CGFloat = 0
            color.getRed(&red, green: &green, blue: &blue, alpha: nil)
            let cssColor = String(format: "#%02x%02x%02x", Int(red * 255.0), Int(green * 255.0), Int(blue * 255.0))
            let style = """
            font-family:'\(font.fontName)'; font-size:\(font.pointSize)px; color:\(cssColor);
            """
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
