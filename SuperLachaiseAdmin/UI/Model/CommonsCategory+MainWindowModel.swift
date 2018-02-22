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
                DetailViewFieldItem(name: "ID", value: commonsCategoryId),
            ],
            [
                DetailViewFieldItem(name: "Default sort", value: defaultSort),
            ],
            [
                DetailViewFieldItem(name: "Main Commons File ID", value: mainCommonsFileId),
            ],
        ])
    }

}
