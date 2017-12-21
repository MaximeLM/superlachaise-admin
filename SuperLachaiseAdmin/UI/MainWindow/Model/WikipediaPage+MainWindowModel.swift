//
//  WikipediaPage+MainWindowModel.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 21/12/2017.
//

import Foundation

extension WikipediaPage: MainWindowModelType {

    func detailViewModel() -> DetailViewModel {
        return DetailViewModel(self, items: [
            [
                DetailViewFieldItem(name: "Name", value: name),
                DetailViewFieldItem(name: "Language", value: wikipediaId?.language),
                DetailViewFieldItem(name: "Title", value: wikipediaId?.title),
            ],
            [
                DetailViewFieldItem(name: "Abstract", value: abstract),
                DetailViewFieldItem(name: "Default sort", value: defaultSort),
            ],
        ])
    }

}
