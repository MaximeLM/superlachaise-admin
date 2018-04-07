//
//  NSNib+Instantiate.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 17/12/2017.
//

import Cocoa

extension NSNib {

    static func instantiate<T>(_ nibName: String, bundle: Bundle? = nil, owner: Any? = nil) -> T? {
        guard let nib = NSNib(nibNamed: NSNib.Name(rawValue: nibName), bundle: bundle) else {
            assertionFailure()
            return nil
        }
        return nib.instantiate(owner: owner)
    }

    func instantiate<T>(owner: Any? = nil) -> T? {
        var topLevelObjects: NSArray?
        guard instantiate(withOwner: owner, topLevelObjects: &topLevelObjects) else {
            assertionFailure()
            return nil
        }
        guard let topLevelObject = (topLevelObjects?.compactMap { $0 as? T }.first) else {
            assertionFailure()
            return nil
        }
        return topLevelObject
    }

}
