//
//  MediaImporterLoggingProxy.swift
//  VideoPlayer
//
//  Created by Maxim Vynnyk on 16.04.2023.
//

import Foundation
import UIKit
import PhotosUI
import SwiftUI
import Combine

public final class MediaImporterLoggingProxy: MediaImporterProtocol {
    private let mediaImporter: MediaImporterProtocol
    private let logger: Logger
    
    public init(mediaImporter: MediaImporterProtocol, logger: Logger) {
        self.mediaImporter = mediaImporter
        self.logger = logger
    }
    
    public func loadVideo(from selection: PhotosPickerItem) async -> VideoModel? {
        logger.log(event: .startImportingVideo())
        let result = await mediaImporter.loadVideo(from: selection)
        
        if let preview = result?.imageURL {
            logger.log(event: .generatedPreview(path: preview.path()))
        }
        
        if let result {
            logger.log(event: .videoImportedSuccess(videoPath: result.videoURL.path()))
        }
        
        logger.log(event: .finishImportingVideo())
        return result
    }
    
    public func loadImage(from selection: PhotosPickerItem) async -> (UIImage?, URL?) {
        logger.log(event: .startImportingImage())
        let (image, url) = await mediaImporter.loadImage(from: selection)
        
        if image != nil, let url {
            logger.log(event: .imageImportedSuccess(path: url.path()))
        }
        
        logger.log(event: .finishImportingImage())
        return (image, url)
    }
}
