//
//  WikidataEntry+RootViewSource.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 17/12/2017.
//

import Foundation

extension WikidataEntry: RootViewSource {

    func rootViewModel() -> RootViewModel {
        return RootViewModel(self, subviews: [
            [
                DetailViewFieldView.instantiate(name: "Name",
                                                value: name),
                DetailViewFieldView.instantiate(name: "ID",
                                                value: wikidataId),
            ],
            [
                DetailViewFieldView.instantiate(name: "Nature",
                                                value: nature),
                DetailViewFieldView.instantiate(name: "Date of birth",
                                                value: dateOfBirth),
                DetailViewFieldView.instantiate(name: "Date of death",
                                                value: dateOfDeath),
            ],
            [
                DetailViewFieldView.instantiate(name: "Secondary Wikidata IDs",
                                                value: Array(secondaryWikidataIds)),
                DetailViewFieldView.instantiate(name: "Wikidata categories ID",
                                                value: Array(wikidataCategoryIds)),
            ],
        ])
    }

}
