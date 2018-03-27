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
                DetailViewImageItem(url: image?.thumbnailURL(height: 400)),
                DetailViewFieldItem(name: "Name", value: name),
                DetailViewFieldItem(name: "ID", value: wikidataId),
            ],
            [
                DetailViewFieldItem(name: "Kind", value: kind),
                DetailViewFieldItem(name: "Date of birth", value: dateOfBirth),
                DetailViewFieldItem(name: "Date of death", value: dateOfDeath),
            ],
            [
                DetailViewToOneFieldItem(name: "Image", value: image),
            ],
            localizationsFields(),
        ])
    }

    private func localizationsFields() -> [DetailViewInlineFieldItem] {
        return localizations.map {
            DetailViewInlineFieldItem(name: "Localization: \($0.language)", valueItems: [
                DetailViewFieldItem(name: "Name", value: $0.name),
                DetailViewFieldItem(name: "Description", value: $0.summary),
                DetailViewFieldItem(name: "Default sort", value: $0.defaultSort),
                DetailViewFieldItem(name: "Wikipedia title", value: $0.wikipediaTitle),
                DetailViewHTMLFieldItem(name: "Wikipedia extract", value: $0.wikipediaExtract),
                DetailViewFieldItem(name: "Wikipedia extract (raw)", value: $0.wikipediaExtract),
            ])
        }
    }

}
