//
//  MainWindowModel.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 20/12/2017.
//

import CoreData
import Foundation
import RxSwift

typealias MainWindowModel = NSManagedObject & MainWindowModelType

protocol MainWindowModelType: Identifiable {

    var mainWindowTitle: String { get }

    func detailViewModel() -> DetailViewModel

}

extension MainWindowModelType {

    var mainWindowTitle: String {
        return "\(type(of: self)): \(self)"
    }

}
