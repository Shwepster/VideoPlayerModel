//
//  File.swift
//  
//
//  Created by Maxim Vynnyk on 09.05.2023.
//

import Foundation

extension FileManager {
    func removeIfExists(at url: URL) throws {
        if fileExists(atPath: url.path()) {
            try removeItem(at: url)
        }
    }
}
