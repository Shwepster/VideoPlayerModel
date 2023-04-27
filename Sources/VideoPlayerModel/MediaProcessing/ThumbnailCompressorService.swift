//
//  ThumbnailCompressorService.swift
//  VideoPlayer
//
//  Created by Maxim Vynnyk on 17.04.2023.
//

import UIKit

final class ThumbnailCompressorService {
    static let shared = ThumbnailCompressorService()
    private let manager = FileManager.default
    private let compression: CGFloat = 0.2
    private init() {}
    
    func findAndCompressAll() {
        Task {
            let directory = URL.getDocumentsDirectory()
            do {
                let content = try manager.contentsOfDirectory(atPath: directory.path())
                    .filter {
                        $0.hasSuffix(".png") || $0.hasSuffix(".jpeg")
                    }
                
                try content.forEach { name in
                    let url = directory.appending(path: name)
                    print(url)
                    try compressImage(at: url)
                }
                
                print(content)
            } catch let error {
                print(error)
            }
        }
    }
    
    func compressImage(at url: URL) throws {
        guard let image = UIImage(contentsOfFile: url.path()),
              let data = image.jpegData(compressionQuality: compression)
        else { return }
        
        try data.write(to: url)
        print("Did compress at:\n\(url)")
    }
}
