//
//  ImportingChain.swift
//  VideoPlayer
//
//  Created by Maxim Vynnyk on 18.04.2023.
//

import Foundation
import SwiftUI
import PhotosUI

protocol ImportingHandler: AnyObject {
    var next: ImportingHandler? { get set }
    
    @discardableResult
    func setNext(_ next: ImportingHandler) -> ImportingHandler
    func handleVideo(_ video: VideoModel) async -> VideoModel
}

extension ImportingHandler {
    @discardableResult
    func setNext(_ next: ImportingHandler) -> ImportingHandler {
        self.next = next
        return next
    }
    
    func handleVideo(_ video: VideoModel) async -> VideoModel {
        await next?.handleVideo(video) ?? video
    }
}

final class PreviewGenerationImportingHandler: ImportingHandler {
    var next: ImportingHandler?
    private var previewGenerator = PreviewGenerator.shared
    
    func handleVideo(_ video: VideoModel) async -> VideoModel {
        let previewURL = await previewGenerator.generatePreview(for: video)
        var video = video
        video.imageURL = previewURL
        return await next?.handleVideo(video) ?? video
    }
}

final class PreviewCompressorImportingHandler: ImportingHandler {
    var next: ImportingHandler?
    private var compressor = ThumbnailCompressorService.shared
    
    func handleVideo(_ video: VideoModel) async -> VideoModel {
        if let url = video.imageURL {
            try? compressor.compressImage(at: url)
        }
        
        return await next?.handleVideo(video) ?? video
    }
}
