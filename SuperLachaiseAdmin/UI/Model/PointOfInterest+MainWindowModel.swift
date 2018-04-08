//
//  PointOfInterest+MainWindowModel.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 20/12/2017.
//

import Foundation

extension PointOfInterest: MainWindowModelType {

    func detailViewModel() -> DetailViewModel {
        return DetailViewModel(self, items: [
            [
                DetailViewImageItem(url: image?.thumbnailURL(height: 400)),
                DetailViewFieldItem(name: "Name", value: name),
                DetailViewFieldItem(name: "ID", value: id),
            ],
            [
                DetailViewFieldItem(name: "Latitude", value: latitude),
                DetailViewFieldItem(name: "Longitude", value: longitude),
            ],
            [
                DetailViewToOneFieldItem(name: "Main entry", value: mainEntry),
                DetailViewToManyFieldItem(name: "Secondary entries",
                                          value: Array(secondaryEntries.sorted(byKeyPath: "name"))),
                DetailViewToOneFieldItem(name: "Image", value: image),
            ],
        ])
    }

}
