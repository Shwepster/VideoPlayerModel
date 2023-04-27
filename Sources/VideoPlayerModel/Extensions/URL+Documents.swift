//
//  URL+Documents.swift
//  VideoPlayer
//
//  Created by Maxim Vynnyk on 05.04.2023.
//

import Foundation

extension URL {
    static func getDocumentsDirectory() -> URL {
        guard let documentDirectory = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first else {
            fatalError("no documents directory")
        }
        
        return documentDirectory
    }
    
    static func getPath(for name: String, format: String? = nil) -> URL {
        let directory = getDocumentsDirectory()
        let fileName = format == nil ? name : "\(name).\(format!)"
        let fullURL = directory.appending(path: fileName)
        return fullURL
    }
}
