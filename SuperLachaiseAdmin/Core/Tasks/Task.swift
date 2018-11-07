//
//  Task.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 28/11/2017.
//

import CoreData
import Foundation
import RxSwift

protocol Task: CustomStringConvertible {

    func asSingle() -> Single<Void>

}

protocol CoreDataTask: CustomStringConvertible {

    func asSingle(context: NSManagedObjectContext) -> Single<Void>

}
