//
//  CommonsFile+MainWindowModel.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 02/03/2018.
//

import Foundation

extension CommonsFile: MainWindowModelType {

    func detailViewModel() -> DetailViewModel {
        return DetailViewModel(self, items: [
            [
                DetailViewFieldItem(name: "Commons ID", value: commonsId),
            ],
            [
                DetailViewFieldItem(name: "Width", value: width),
                DetailViewFieldItem(name: "Height", value: height),
            ],
            [
                DetailViewURLFieldItem(name: "Image URL", value: imageURL),
                DetailViewFieldItem(name: "Thumbnail URL template", value: thumbnailURLTemplate),
            ],
            [
                DetailViewFieldItem(name: "Author", value: author),
                DetailViewFieldItem(name: "License", value: license),
            ],
        ])
    }

}
