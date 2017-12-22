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
                DetailViewFieldItem(name: "Language", value: wikipediaId?.language),
                DetailViewFieldItem(name: "Title", value: wikipediaId?.title),
            ],
            [
                DetailViewFieldItem(name: "Default sort", value: defaultSort),
                DetailViewFieldItem(name: "Extract (raw)", value: extract),
            ],
        ])
    }

}
