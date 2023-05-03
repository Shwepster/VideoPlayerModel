//
//  PersistentContainerSynchronized.swift
//  
//
//  Created by Maxim Vynnyk on 04.05.2023.
//

import CoreData

final class PersistentContainerSynchronized: NSPersistentContainer, PersistentContainer {
    var persistentContainer: NSPersistentContainer { self } // Ми і є СБУ, долбойоб.
    
    private lazy var backgroundContext = newBackgroundContext()
    private lazy var storageQueue = PersistentContainerQueue(
        write: context(.background),
        read: context(.main)
    )
    
    // MARK: - Public
    
    func getObjects<T: BaseCDM>(_ predicate: NSPredicate? = nil) async throws -> [T] {
        try await getObjects(predicate, in: .main)
    }
    
    func getObject<T: BaseCDM>(predicate: NSPredicate) async throws -> T? {
        try await getObjects(predicate, in: .main).first
    }
    
    /// Updates object. If it does not exist - creates it
    func saveObject<T: BaseCDM>(type: T.Type, data: Any, predicate: NSPredicate) async throws {
        let object: T? = try await getObject(predicate: predicate, in: .background)
        
        try await withCheckedThrowingContinuation { continuation in
            storageQueue.write {
                do {
                    if let object {
                        object.update(data)
                        try self.saveContext(.background)
                    } else {
                        try self.createObject(type: type, data: data)
                    }
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    func deleteObjects<T: BaseCDM>(of type: T.Type, predicate: NSPredicate) async throws {
        let a: [T] = try await getObjects(predicate, in: .background)
        a.forEach { object in
            context(.background).delete(object)
        }
        try saveContext(.background)
    }
    
    // MARK: - Private
    
    private func getObjects<T: BaseCDM>(_ predicate: NSPredicate? = nil, in context: ContextType) async throws -> [T] {
        try await withCheckedThrowingContinuation { continuation in
            storageQueue.read {
                let request = T.fetchRequest(predicate: predicate)
                do {
                    let objects = try self.context(context).fetch(request)
                    continuation.resume(returning: objects)
                } catch let error {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    private func getObject<T: BaseCDM>(predicate: NSPredicate, in context: ContextType) async throws -> T? {
        try await getObjects(predicate, in: context).first
    }
    
    private func createObject<T: BaseCDM>(type: T.Type, data: Any) throws {
        let object = T(context: context(.background))
        object.update(data)
        try saveContext(.background)
    }
    
    private func saveContext(_ context: ContextType = .main) throws {
        let context = self.context(context)
        try saveContext(context)
    }
    
    private func context(_ type: ContextType) -> NSManagedObjectContext {
        switch type {
        case .main:
           return viewContext
        case .background:
            return backgroundContext
        }
    }
}
