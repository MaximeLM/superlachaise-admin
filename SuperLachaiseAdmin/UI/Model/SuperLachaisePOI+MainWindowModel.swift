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
                DetailViewImageItem(url: image?.thumbnailURL(height: 400)),
                DetailViewFieldItem(name: "Name", value: name),
                DetailViewFieldItem(name: "ID", value: wikidataId),
            ],
            [
                DetailViewToOneFieldItem(name: "OpenStreetMap element", value: openStreetMapElement),
                DetailViewToOneFieldItem(name: "Primary Wikidata entry", value: primaryWikidataEntry),
                DetailViewToManyFieldItem(name: "Secondary Wikidata entries", value: Array(secondaryWikidataEntries)),
                DetailViewToOneFieldItem(name: "Image", value: image),
            ],
        ])
    }

}
