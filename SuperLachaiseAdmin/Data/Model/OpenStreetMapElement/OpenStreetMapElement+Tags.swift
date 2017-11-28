//
//  OpenStreetMapElement+Tags.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 28/11/2017.
//

import Foundation

extension OpenStreetMapElement {

    var tags: [String: String] {
        get {
            guard let rawTags = rawTags else {
                return [:]
            }
            do {
                return try JSONDecoder().decode([String: String].self, from: rawTags)
            } catch {
                assertionFailure("\(error)")
                return [:]
            }
        }
        set {
            do {
                rawTags = try JSONEncoder().encode(newValue)
            } catch {
                assertionFailure("\(error)")
            }
        }
    }

}
