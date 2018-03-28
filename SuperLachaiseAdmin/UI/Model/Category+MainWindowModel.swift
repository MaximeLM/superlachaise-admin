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
        ])
    }

    private func localizationsFields() -> [DetailViewInlineFieldItem] {
        return localizations.map {
            DetailViewInlineFieldItem(name: "Localization: \($0.language)", valueItems: [
                DetailViewFieldItem(name: "Name", value: $0.name),
            ])
        }
    }

}
