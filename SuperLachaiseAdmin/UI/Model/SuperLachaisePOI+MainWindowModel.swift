//
//  SuperLachaisePOI+MainWindowModel.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 20/12/2017.
//

import Foundation

extension SuperLachaisePOI: MainWindowModelType {

    func detailViewModel() -> DetailViewModel {
        return DetailViewModel(self, items: [
            [
                DetailViewFieldItem(name: "Name", value: name),
                DetailViewFieldItem(name: "ID", value: id),
            ],
            [
                DetailViewFieldItem(name: "Latitude", value: latitude),
                DetailViewFieldItem(name: "Longitude", value: longitude),
            ],
        ])
    }

}
