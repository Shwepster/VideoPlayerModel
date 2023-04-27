//
//  VideoCDM+CoreDataProperties.swift
//  
//
//  Created by Maxim Vynnyk on 05.04.2023.
//
//

import Foundation
import CoreData

extension VideoCDM {
    @NSManaged var id: String
    @NSManaged var title: String
    @NSManaged var videoPath: String
    @NSManaged var imagePath: String?
    
    func update(_ data: Any) {
        guard let video = data as? VideoModel else { return }
        
        id = video.id
        title = video.title
        videoPath = video.videoURL.lastPathComponent
        imagePath = video.imageURL?.lastPathComponent
    }
}
