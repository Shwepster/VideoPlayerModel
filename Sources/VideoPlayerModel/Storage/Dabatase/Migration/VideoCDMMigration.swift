//
//  VideoCDMMigration.swift
//  VideoPlayer
//
//  Created by Maxim Vynnyk on 06.04.2023.
//

import CoreData

final class VideoCDMMigration: NSEntityMigrationPolicy {
    override func createDestinationInstances(forSource sInstance: NSManagedObject,
                                             in mapping: NSEntityMapping, manager: NSMigrationManager) throws {
        try super.createDestinationInstances(forSource: sInstance, in: mapping, manager: manager)
        
        let sourceImageURL = sInstance.value(forKey: "imageURL") as? URL
        let sourceVideoURL = sInstance.value(forKey: "videoURL") as! URL
        
        let destenationImagePath = sourceImageURL?.lastPathComponent
        let destenationVideoPath = sourceVideoURL.lastPathComponent
                
        let destenation = manager.destinationInstances(
            forEntityMappingName: mapping.name,
            sourceInstances: [sInstance]
        ).last
        
        guard let destenation else { fatalError("Destenation instance is not created") }
        
        destenation.setValuesForKeys([
            "imagePath": destenationImagePath as Any,
            "videoPath": destenationVideoPath
        ])
        
        NSLog("Migration success!")
    }
}
