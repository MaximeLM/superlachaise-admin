//
//  Errors.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 28/11/2017.
//

import Foundation

func assertIsMainThread() {
    assert(Thread.current.isMainThread)
}

enum Errors: Error {
    case notImplemented
    case invalidBoundingBox([Double])
    case invalidInvalidOpenStreetMapId(String)
    case configNotFound
}
