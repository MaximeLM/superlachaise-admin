//
//  Collections+UniqueValues.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 14/12/2017.
//

import Foundation

extension Array where Element: Hashable {

    func uniqueValues() -> [Element] {
        return Array(Set(self))
    }

}
