//
//  WikidataCategory+MainWindowModel.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 03/03/2018.
//

import Foundation

extension WikidataCategory: MainWindowModelType {

    func detailViewModel() -> DetailViewModel {
        return DetailViewModel(self, items: [
            [
                DetailViewFieldItem(name: "Name", value: name),
                DetailViewFieldItem(name: "ID", value: wikidataId),
            ],
        ])
    }

}
