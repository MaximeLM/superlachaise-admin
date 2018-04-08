//
//  Entry+MainWindowModel.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 25/03/2018.
//

import Foundation

extension Entry: MainWindowModelType {

    func detailViewModel() -> DetailViewModel {
        return DetailViewModel(self, items: [
            [
                DetailViewImageItem(commonsFile: image),
                DetailViewFieldItem(name: "Name", value: name),
                DetailViewFieldItem(name: "ID", value: id),
            ],
            [
                DetailViewFieldItem(name: "Kind", value: kind),
                DetailViewFieldItem(name: "Date of birth", value: dateOfBirth),
                DetailViewFieldItem(name: "Date of death", value: dateOfDeath),
            ],
            [
                DetailViewToOneFieldItem(name: "Image", value: image),
                DetailViewToManyFieldItem(name: "Categories", value: Array(categories)),
            ],
            localizationsFields(),
        ])
    }

    private func localizationsFields() -> [DetailViewInlineFieldItem] {
        return localizations
            .map {
                DetailViewInlineFieldItem(name: "Localization: \($0.language)", valueItems: [
                    DetailViewFieldItem(name: "Name", value: $0.name),
                    DetailViewFieldItem(name: "Description", value: $0.summary),
                    DetailViewFieldItem(name: "Default sort", value: $0.defaultSort),
                    DetailViewToOneFieldItem(name: "Wikipedia page", value: $0.wikipediaPage),
                ])
            }
    }

}
