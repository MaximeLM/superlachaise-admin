//
//  WikidataEntry+MainWindowModel.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 20/12/2017.
//

import Foundation

extension WikidataEntry: MainWindowModelType {

    func detailViewModel() -> DetailViewModel {
        return DetailViewModel(self, items: [
            [
                DetailViewFieldItem(name: "Name", value: name),
                DetailViewFieldItem(name: "ID", value: wikidataId),
            ],
            localizationsFields(),
            [
                DetailViewFieldItem(name: "Nature", value: nature),
                DetailViewFieldItem(name: "Date of birth", value: dateOfBirth),
                DetailViewFieldItem(name: "Date of death", value: dateOfDeath),
            ],
            [
                DetailViewToManyFieldItem(name: "Secondary Wikidata entries", value: Array(secondaryWikidataEntries)),
                DetailViewToManyFieldItem(name: "Wikidata categories", value: Array(wikidataCategories)),
                DetailViewToOneFieldItem(name: "Image", value: image),
                DetailViewToOneFieldItem(name: "Image of grave", value: imageOfGrave),
            ],
        ])
    }

    private func localizationsFields() -> [DetailViewInlineFieldItem] {
        return localizations.map {
            DetailViewInlineFieldItem(name: "Localization: \($0.language)", valueItems: [
                DetailViewFieldItem(name: "Name", value: $0.name),
                DetailViewFieldItem(name: "Description", value: $0.summary),
                DetailViewToOneFieldItem(name: "Wikipedia page", value: $0.wikipediaPage),
            ])
        }
    }

}
