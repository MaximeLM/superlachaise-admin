//
//  Results.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 07/11/2018.
//

import CoreData
import Foundation

final class Results<Object: NSManagedObject> {

    let context: NSManagedObjectContext
    let predicates: [NSPredicate]
    let sortDescriptors: [NSSortDescriptor]

    init(context: NSManagedObjectContext, predicates: [NSPredicate] = [], sortDescriptors: [NSSortDescriptor] = []) {
        self.context = context
        self.predicates = predicates
        self.sortDescriptors = sortDescriptors
    }

    // MARK: Filter

    func filtered(by predicate: NSPredicate) -> Results<Object> {
        var predicates = self.predicates
        predicates.append(predicate)
        return Results(context: context, predicates: predicates, sortDescriptors: sortDescriptors)
    }

    func filtered(by predicateFormat: String, _ argumentArray: [Any]? = nil) -> Results<Object> {
        let predicate = NSPredicate(format: predicateFormat, argumentArray: argumentArray)
        return filtered(by: predicate)
    }

    // MARK: Sort

    func sorted(by sortDescriptor: NSSortDescriptor) -> Results<Object> {
        var sortDescriptors = self.sortDescriptors
        sortDescriptors.append(sortDescriptor)
        return Results(context: context, predicates: predicates, sortDescriptors: sortDescriptors)
    }

    func sorted(byKey key: String, ascending: Bool = true) -> Results<Object> {
        return sorted(by: NSSortDescriptor(key: key, ascending: ascending))
    }

    // MARK: Fetch

    func fetchRequest() -> NSFetchRequest<Object> {
        let fetchRequest = NSFetchRequest<Object>()
        fetchRequest.entity = Object.entity()
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        fetchRequest.sortDescriptors = sortDescriptors
        return fetchRequest
    }

    func fetch() -> [Object] {
        do {
            return try context.fetch(fetchRequest())
        } catch {
            assertionFailure("\(error)")
            return []
        }
    }

    func count() -> Int {
        do {
            return try context.count(for: fetchRequest())
        } catch {
            assertionFailure("\(error)")
            return 0
        }
    }

}
