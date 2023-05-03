//
//  MediaImporter.swift
//  VideoPlayer
//
//  Created by Maxim Vynnyk on 04.04.2023.
//

import PhotosUI
import SwiftUI
import Combine
import AVKit

public protocol MediaImporterProtocol {
    /// Creates `VideoModel` from selected video and saves it to storage
    /// - Parameter selection: Selected item from which to import video file
    /// - Returns: Created video model object
    func loadVideo(from selection: PhotosPickerItem) async -> VideoModel?
    
    /// Loads image and saves it to disk
    /// - Parameter selection: Selected item
    /// - Returns: Image and Path if loading was successful
    func loadImage(from selection: PhotosPickerItem) async -> (UIImage?, URL?)
}

public final class MediaImporter: MediaImporterProtocol {
    private var mediaSelection: PhotosPickerItem?
    private let storageService: StorageService
    
    public init(storageService: StorageService = .shared) {
        self.storageService = storageService
    }
    
    public func loadVideo(from selection: PhotosPickerItem) async -> VideoModel? {
        mediaSelection = selection
        
        guard let videoModel = try? await selection.loadTransferable(type: VideoModel.self) else {
            return nil
        }
                
        await storageService.saveVideoAsync(videoModel)
        return videoModel
    }
    
    public func loadImage(from selection: PhotosPickerItem) async -> (UIImage?, URL?) {
        mediaSelection = selection

        do {
            let imageData = try await selection.loadTransferable(type: Data.self)
            
            guard let imageData, let image = UIImage(data: imageData) else {
                return (nil, nil)
            }
            
            let imageURL = try imageData.saveToStorageFile(format: "jpeg")
            return (image, imageURL)
        } catch {
            return (nil, nil)
        }
    }
}
