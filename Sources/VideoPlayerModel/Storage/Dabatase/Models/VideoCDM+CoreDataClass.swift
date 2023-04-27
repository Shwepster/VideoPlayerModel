//
//  VideoCDM+CoreDataClass.swift
//  
//
//  Created by Maxim Vynnyk on 05.04.2023.
//
//

import Foundation
import CoreData

@objc(VideoCDM)
final class VideoCDM: NSManagedObject, BaseCDM {
    static var entityName: String { "VideoCDM" }
    
    typealias Identifier = String
    
    override var description: String {
        "VideoCDM"
    }
}
