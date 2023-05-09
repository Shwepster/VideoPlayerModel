//
//  PersistentContainerQueue.swift
//  
//
//  Created by Maxim Vynnyk on 03.05.2023.
//

import CoreData

final class PersistentContainerQueue {
    typealias Callback = () -> Void
    
    private var readContext: NSManagedObjectContext
    private var writeContext: NSManagedObjectContext
    
    private let readQueue: OperationQueue
    private let writeQueue: OperationQueue
    
    init(write: NSManagedObjectContext, read: NSManagedObjectContext) {
        readContext = read
        writeContext = write
        
        readQueue = OperationQueue()
        readQueue.maxConcurrentOperationCount = 1
        
        writeQueue = OperationQueue()
        writeQueue.maxConcurrentOperationCount = 1        
    }
    
    func read(_ block: @escaping Callback) {
        readQueue.addOperation {
            self.readContext.perform {
                block()
            }
        }
    }
    
    func write(_ block: @escaping Callback) {
        writeQueue.addOperation {
            self.writeContext.perform {
                block()
            }
        }
    }
}
