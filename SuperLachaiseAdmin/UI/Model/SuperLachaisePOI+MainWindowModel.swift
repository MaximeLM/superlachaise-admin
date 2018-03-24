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
                DetailViewFieldItem(name: "Language", value: superLachaiseId?.language),
                DetailViewFieldItem(name: "Wikidata ID", value: superLachaiseId?.wikidataId),
            ],
            [
                DetailViewFieldItem(name: "Latitude", value: latitude),
                DetailViewFieldItem(name: "Longitude", value: longitude),
            ],
        ])
    }

}
