//
//  PreviewGenerator.swift
//  VideoPlayer
//
//  Created by Maxim Vynnyk on 05.04.2023.
//

import AVKit

public final class PreviewGenerator {
    public static let shared = PreviewGenerator()
    private init() {}
    
    func generatePreview(for video: VideoModel) async -> URL? {
        let image = await video.asset.generateThumbnail()
        let thumbnailName = "\(video.id)_thumbnail"
        let thumbnailURL = try? image?
            .jpegData(compressionQuality: 0.25)?
            .saveToStorageFile(name: thumbnailName, format: "jpeg")
        return thumbnailURL
    }
}
