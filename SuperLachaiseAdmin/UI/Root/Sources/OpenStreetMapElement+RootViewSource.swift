//
//  OpenStreetMapElement+RootViewSource.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 17/12/2017.
//

import Foundation

extension OpenStreetMapElement: RootViewSource {

    func rootViewModel() -> RootViewModel {
        return RootViewModel(self, subviews: [
            [
                DetailViewFieldView.instantiate(name: "Name",
                                                value: name),
                DetailViewFieldView.instantiate(name: "Type",
                                                value: openStreetMapId?.elementType),
                DetailViewFieldView.instantiate(name: "ID",
                                                value: openStreetMapId?.numericId),
            ],
            [
                DetailViewFieldView.instantiate(name: "Latitude",
                                                value: latitude),
                DetailViewFieldView.instantiate(name: "Longitude",
                                                value: longitude),
            ],
            [
                DetailViewFieldView.instantiate(name: "Wikidata ID",
                                                value: wikidataId),
            ],
        ])
    }

}
