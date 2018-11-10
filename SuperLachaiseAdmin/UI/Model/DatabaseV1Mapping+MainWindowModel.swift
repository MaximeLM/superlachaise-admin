//
//  DatabaseV1Mapping+MainWindowModel.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 30/03/2018.
//

import Foundation

extension CoreDataDatabaseV1Mapping: MainWindowModelType {

    func detailViewModel() -> DetailViewModel {
        return DetailViewModel(self, items: [
            [
                DetailViewFieldItem(name: "Monument ID", value: id),
            ],
            [
                DetailViewToOneFieldItem(name: "Point of interest", value: pointOfInterest),
            ],
        ])
    }

}
