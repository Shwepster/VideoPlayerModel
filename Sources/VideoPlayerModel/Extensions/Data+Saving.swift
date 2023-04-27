//
//  Data+Saving.swift
//  VideoPlayer
//
//  Created by Maxim Vynnyk on 05.04.2023.
//

import Foundation

extension Data {
    func saveToTempFile(name: String = UUID().uuidString, format: String? = nil) throws -> URL {
        let directory = NSTemporaryDirectory()
        let fileName = format == nil ? name : "\(name).\(format!)"
        let fullURL = NSURL.fileURL(withPathComponents: [directory, fileName])!
        
        try self.write(to: fullURL)
        
        return fullURL
    }
    
    func saveToStorageFile(name: String = UUID().uuidString, format: String? = nil) throws -> URL {
        let url = URL.getPath(for: name, format: format)
        try self.write(to: url)
        return url
    }
}
