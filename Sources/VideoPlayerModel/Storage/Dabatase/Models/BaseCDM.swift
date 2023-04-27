//
//  BaseCDM.swift
//  VideoPlayer
//
//  Created by Maxim Vynnyk on 05.04.2023.
//

import CoreData

protocol BaseCDM: NSManagedObject {
    associatedtype Identifier
    
    static var entityName : String { get }
    static func fetchRequest(predicate: NSPredicate?) -> NSFetchRequest<Self>
    static func objectPredicate(id: Identifier) -> NSPredicate
    func update(_ data: Any)
}

extension BaseCDM {
//    static var entityName: String {
//        String(describing: self)
//    }
    
    static func fetchRequest(predicate: NSPredicate?) -> NSFetchRequest<Self> {
        let request = NSFetchRequest<Self>(entityName: entityName)
        request.predicate = predicate
        return request
    }
    
    static func objectPredicate(id: Identifier) -> NSPredicate {
        .init(format: "id == '\(id)'")
    }
}
