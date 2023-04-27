//
//  MediaImportService.swift
//  Model
//
//  Created by Maxim Vynnyk on 26.04.2023.
//

import Combine
import SwiftUI
import PhotosUI

final public class MediaImportOperation: Operation, ObservableObject {
    private let mediaImporter: MediaImporterProtocol
    let id = UUID().uuidString
    let media: PhotosPickerItem
    let importState = CurrentValueSubject<ImportState, Never>(ImportState.idle)

    init(media: PhotosPickerItem, mediaImporter: MediaImporterProtocol) {
        self.media = media
        self.mediaImporter = mediaImporter
    }
    
    override public func start() {
        super.start()
        importVideo(from: media)
    }
    
    private func importVideo(from selection: PhotosPickerItem) {
        importState.send(.loading)
        
        Task {
            var result = ImportedMedia.empty
            
            if selection.supportedContentTypes.contains(.jpeg) {
                let imageResult = await mediaImporter.loadImage(from: selection)
                if let image = imageResult.0, let url = imageResult.1 {
                    result = .image(image, url)
                }
            } else {
                // is saved in DB during loading
                if let videoModel = await mediaImporter.loadVideo(from: selection) {
                    result = .video(videoModel)
                }
            }
            
            Task { @MainActor [result] in
                importState.send(.loaded(result))
                importState.send(completion: .finished)
            }
        }
    }
}

// MARK: - Enums

extension MediaImportOperation {
    public enum ImportState {
        case loading
        case loaded(ImportedMedia)
        case idle
    }
    
    public enum ImportedMedia {
        case video(VideoModel)
        case image(UIImage, URL)
        case empty
    }
}
