//
//  CommonsCategory+MainWindowModel.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 20/02/2018.
//

import Foundation

extension CommonsCategory: MainWindowModelType {

    func detailViewModel() -> DetailViewModel {
        return DetailViewModel(self, items: [
            [
                DetailViewFieldItem(name: "Name", value: name),
            ],
            [
                DetailViewFieldItem(name: "Default sort", value: defaultSort),
            ],
            [
                DetailViewFieldItem(name: "Main file name", value: mainCommonsFileName),
                DetailViewFieldItem(name: "Files names", value: Array(commonsFilesNames)),
            ],
        ])
    }

}
