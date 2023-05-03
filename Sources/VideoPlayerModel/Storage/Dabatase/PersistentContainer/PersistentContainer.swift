//
//  PersistentContainer.swift
//  VideoPlayer
//
//  Created by Maxim Vynnyk on 05.04.2023.
//

import CoreData

protocol PersistentContainer {
    var persistentContainer: NSPersistentContainer { get }
    func setup()
    func getObjects<T: BaseCDM>(_ predicate: NSPredicate?) async throws -> [T]
    func getObject<T: BaseCDM>(predicate: NSPredicate) async throws -> T?
    /// Updates object. If it does not exist - creates it
    func saveObject<T: BaseCDM>(type: T.Type, data: Any, predicate: NSPredicate) async throws
    func deleteObjects<T: BaseCDM>(of type: T.Type, predicate: NSPredicate) async throws
}

extension PersistentContainer {
    // Do not override, because of static dispatch
    func saveContext(_ context: NSManagedObjectContext) throws {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                context.rollback()
                fatalError("\(error.nsError.localizedDescription), \(error.nsError.userInfo)")
                throw error
            }
        }
    }
    
    func setup() {
        let storeDescription = NSPersistentStoreDescription()
        storeDescription.shouldMigrateStoreAutomatically = true
        storeDescription.shouldInferMappingModelAutomatically = false // because we have custom mapper
        persistentContainer.persistentStoreDescriptions.append(storeDescription)
        
        persistentContainer.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }
        }
        
        persistentContainer.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        persistentContainer.viewContext.shouldDeleteInaccessibleFaults = true
        persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
    }
}

enum ContextType {
    case main
    case background
}
