//
//  DetailViewSource.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 18/12/2017.
//

import Foundation

protocol DetailViewSource: RealmIdentifiable {

    func detailViewModel() -> DetailViewModel

}
