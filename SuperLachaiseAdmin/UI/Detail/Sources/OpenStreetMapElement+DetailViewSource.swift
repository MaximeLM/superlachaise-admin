//
//  OpenStreetMapElement+DetailViewSource.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 17/12/2017.
//

import Foundation

extension OpenStreetMapElement: DetailViewSource {

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
            [
                DetailViewFieldItem(name: "Wikidata ID", value: wikidataId),
            ],
        ])
    }

}
