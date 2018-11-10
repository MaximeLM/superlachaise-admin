//
//  Category+MainWindowModel.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 28/03/2018.
//

import Foundation

extension CoreDataCategory: MainWindowModelType {

    func detailViewModel() -> DetailViewModel {
        return DetailViewModel(self, items: [
            [
                DetailViewFieldItem(name: "ID", value: id),
            ],
            localizationsFields(),
            [
                //DetailViewToManyFieldItem(name: "Entries", value: Array(entries.sorted(byKeyPath: "name"))), // TODO
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
