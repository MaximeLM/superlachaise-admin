//
//  OpenStreetMapElement+MainWindowModel.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 20/12/2017.
//

import Foundation

extension OpenStreetMapElement: MainWindowModelType {

    func detailViewModel() -> DetailViewModel {
        return DetailViewModel(self, items: [
            [
                DetailViewFieldItem(name: "Name", value: name),
                DetailViewFieldItem(name: "Type", value: openStreetMapId?.elementType),
                DetailViewFieldItem(name: "ID", value: openStreetMapId?.numericId),
            ],
            [
                DetailViewFieldItem(name: "Latitude", value: latitude),
                DetailViewFieldItem(name: "Longitude", value: longitude),
            ],
            /*[
                DetailViewToOneFieldItem(name: "Wikidata entry", value: wikidataEntry),
            ],*/
        ])
    }

}
