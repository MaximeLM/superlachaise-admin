//
//  PointOfInterest+MainWindowModel.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 20/12/2017.
//

import Foundation

extension CoreDataPointOfInterest: MainWindowModelType {

    func detailViewModel() -> DetailViewModel {
        return DetailViewModel(self, items: [
            [
                DetailViewImageItem(commonsFile: image),
                DetailViewFieldItem(name: "Name", value: name),
                DetailViewFieldItem(name: "ID", value: id),
            ],
            [
                DetailViewToOneFieldItem(name: "OpenStreetMap element", value: openStreetMapElement),
                //DetailViewToOneFieldItem(name: "Main entry", value: mainEntry), // TODO
                //DetailViewToManyFieldItem(name: "Secondary entries", value: Array(secondaryEntries)), // TODO
                DetailViewToOneFieldItem(name: "Image", value: image),
            ],
        ])
    }

}
