//
//  WikidataEntry+DetailViewSource.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 17/12/2017.
//

import Foundation

extension WikidataEntry: DetailViewSource {

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
                DetailViewFieldItem(name: "Secondary Wikidata IDs", value: Array(secondaryWikidataIds)),
                DetailViewFieldItem(name: "Wikidata categories IDs", value: Array(wikidataCategoriesIds)),
                DetailViewFieldItem(name: "Commons category ID", value: commonsCategoryId),
            ],
        ])
    }

    private func localizationsFields() -> [DetailViewInlineFieldItem] {
        return localizations.map {
            DetailViewInlineFieldItem(name: "Localization: \($0.language)", valueItems: [
                DetailViewFieldItem(name: "Name", value: $0.name),
                DetailViewFieldItem(name: "Description", value: $0.summary),
                DetailViewFieldItem(name: "Wikipedia title", value: $0.wikipediaTitle),
            ])
        }
    }

}
