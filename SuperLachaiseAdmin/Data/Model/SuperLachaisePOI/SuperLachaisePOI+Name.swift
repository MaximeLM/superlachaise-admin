//
//  SuperLachaisePOI+Name.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 03/12/2017.
//

import Foundation

extension SuperLachaisePOI {

    func updateName() {
        self.name = openStreetMapElement?.name
    }

}
