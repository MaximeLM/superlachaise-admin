//
//  WikidataEntry+RootViewSource.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 17/12/2017.
//

import Foundation

extension WikidataEntry: RootViewSource {

    func rootViewModel() -> RootViewModel {
        return RootViewModel(self, items: [
            [
                DetailViewFieldItem(name: "Name", value: name),
                DetailViewFieldItem(name: "ID", value: wikidataId),
            ],
            [
                DetailViewFieldItem(name: "Nature", value: nature),
                DetailViewFieldItem(name: "Date of birth", value: dateOfBirth),
                DetailViewFieldItem(name: "Date of death", value: dateOfDeath),
            ],
            [
                DetailViewFieldItem(name: "Secondary Wikidata IDs", value: Array(secondaryWikidataIds)),
                DetailViewFieldItem(name: "Wikidata categories IDs", value: Array(wikidataCategoryIds)),
            ],
        ])
    }

}
