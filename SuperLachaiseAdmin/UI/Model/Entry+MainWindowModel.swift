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
                DetailViewFieldItem(name: "Name", value: name),
                DetailViewFieldItem(name: "ID", value: wikidataId),
            ],
            localizationsFields(),
            [
                DetailViewFieldItem(name: "Kind", value: kind),
                DetailViewFieldItem(name: "Date of birth", value: dateOfBirth),
                DetailViewFieldItem(name: "Date of death", value: dateOfDeath),
            ],
        ])
    }

    private func localizationsFields() -> [DetailViewInlineFieldItem] {
        return localizations.map {
            DetailViewInlineFieldItem(name: "Localization: \($0.language)", valueItems: [
                DetailViewFieldItem(name: "Name", value: $0.name),
                DetailViewFieldItem(name: "Description", value: $0.summary),
                DetailViewHTMLFieldItem(name: "Extract", value: $0.wikipediaExtract),
                DetailViewFieldItem(name: "Extract (raw)", value: $0.wikipediaExtract),
            ])
        }
    }

}
