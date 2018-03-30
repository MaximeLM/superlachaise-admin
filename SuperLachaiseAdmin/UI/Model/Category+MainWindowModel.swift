//
//  Category+MainWindowModel.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 28/03/2018.
//

import Foundation

extension Category: MainWindowModelType {

    func detailViewModel() -> DetailViewModel {
        return DetailViewModel(self, items: [
            [
                DetailViewFieldItem(name: "ID", value: id),
            ],
            localizationsFields(),
            [
                DetailViewToManyFieldItem(name: "Wikidata categories", value: Array(wikidataCategories)),
            ],
        ])
    }

    private func localizationsFields() -> [DetailViewFieldItem] {
        return localizations
            .filter("isDeleted == false")
            .map {
                DetailViewFieldItem(name: "Name: \($0.language)", value: $0.name)
            }
    }

}