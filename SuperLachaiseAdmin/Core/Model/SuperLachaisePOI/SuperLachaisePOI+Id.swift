//
//  SuperLachaisePOI+Id.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 24/03/2018.
//

import Foundation

struct SuperLachaiseId {
    let language: String
    let wikidataId: String
}

extension SuperLachaiseId: Equatable, CustomStringConvertible {

    init?(rawValue: String) {
        let components = rawValue.components(separatedBy: "/")
        guard components.count == 2 else {
            return nil
        }
        self.init(language: components[0], wikidataId: components[1])
    }

    var rawValue: String {
        return "\(language)/\(wikidataId)"
    }

    static func == (lhs: SuperLachaiseId, rhs: SuperLachaiseId) -> Bool {
        return lhs.language == rhs.language && lhs.wikidataId == rhs.wikidataId
    }

    var description: String {
        return rawValue
    }

}

extension SuperLachaisePOI {

    var superLachaiseId: SuperLachaiseId? {
        get {
            guard let superLachaiseId = SuperLachaiseId(rawValue: rawSuperLachaiseId) else {
                assertionFailure()
                return nil
            }
            return superLachaiseId
        }
        set {
            rawSuperLachaiseId = newValue?.rawValue ?? ""
        }
    }

}
