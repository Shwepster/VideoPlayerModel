//
//  PersistentContainerActor.swift
//  
//
//  Created by Maxim Vynnyk on 04.05.2023.
//

import CoreData

extension NSPredicate: @unchecked Sendable {}

actor PersistentContainerActor: PersistentContainer {
    let persistentContainer: NSPersistentContainer
    private lazy var backgroundContext = persistentContainer.newBackgroundContext()
    
    init(name: String, managedObjectModel: NSManagedObjectModel) {
        persistentContainer = .init(name: name, managedObjectModel: managedObjectModel)
    }
    
    // MARK: - Public
    
    func getObjects<T: BaseCDM>(_ predicate: NSPredicate?) async throws -> [T] {
        try getObjects(predicate, in: .main)
    }
    
    func getObject<T: BaseCDM>(predicate: NSPredicate) async throws -> T? {
        try getObjects(predicate, in: .main).first
    }
    
    func saveObject<T: BaseCDM>(type: T.Type, data: Any, predicate: NSPredicate) async throws {
        let object: T? = try getObject(predicate: predicate, in: .background)
        
        if let object {
            object.update(data)
            try saveContext(.background)
        } else {
            try createObject(type: type, data: data)
        }
    }
    
    func deleteObjects<T: BaseCDM>(of type: T.Type, predicate: NSPredicate) async throws {
        let a: [T] = try getObjects(predicate, in: .background)
        a.forEach { object in
            context(.background).delete(object)
        }
        try saveContext(.background)
    }
    
    // MARK: - Private
    
    private func context(_ type: ContextType) -> NSManagedObjectContext {
        switch type {
        case .main:
            return persistentContainer.viewContext
        case .background:
            return backgroundContext
        }
    }
    
    private func saveContext(_ context: ContextType = .main) throws {
        let context = self.context(context)
        try saveContext(context)
    }
    
    private func getObject<T: BaseCDM>(predicate: NSPredicate, in context: ContextType) throws -> T? {
        try getObjects(predicate, in: context).first
    }
    
    private func getObjects<T: BaseCDM>(_ predicate: NSPredicate? = nil, in context: ContextType) throws -> [T] {
        let request = T.fetchRequest(predicate: predicate)
        let objects = try self.context(context).fetch(request)
        return objects
    }
    
    private func createObject<T: BaseCDM>(type: T.Type, data: Any) throws {
        let object = T(context: context(.background))
        object.update(data)
        try saveContext(.background)
    }
}
