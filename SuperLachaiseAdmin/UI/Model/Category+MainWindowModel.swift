//
//  Category+MainWindowModel.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 28/03/2018.
//

import Foundation

extension Category: MainWindowModelType {

    func detailViewModel() -> DetailViewModel {
        let wikidataCategories = realm?.objects(WikidataCategory.self)
            .filter("ANY categories == %@", self)
        return DetailViewModel(self, items: [
            [
                DetailViewFieldItem(name: "ID", value: id),
            ],
            localizationsFields(),
            [
                DetailViewToManyFieldItem(name: "Wikidata categories",
                                          value: wikidataCategories.map { Array($0) } ?? []),
            ],
        ])
    }

    private func localizationsFields() -> [DetailViewFieldItem] {
        return localizations
            .map {
                DetailViewFieldItem(name: "Name: \($0.language)", value: $0.name)
            }
    }

}
