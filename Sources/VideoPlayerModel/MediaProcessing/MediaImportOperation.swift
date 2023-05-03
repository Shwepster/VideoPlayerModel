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
    @Published var importState = ImportState.idle {
        willSet {
            willChangeValue(forKey: importState.keyPath) // e.g idle
            willChangeValue(forKey: newValue.keyPath) // e.g loading
        }
        didSet {
            didChangeValue(forKey: oldValue.keyPath)
            didChangeValue(forKey: importState.keyPath)
        }
    }

    public override var isAsynchronous: Bool {
        true
    }
    
    public override var isExecuting: Bool {
        importState.isExecuting
    }
    
    public override var isFinished: Bool {
        importState.isFinished
    }
    
    init(media: PhotosPickerItem, mediaImporter: MediaImporterProtocol) {
        self.media = media
        self.mediaImporter = mediaImporter
    }
    
    deinit {
        NSLog("operation dealoc")
    }
    
    override public func start() {
        if isCancelled {
            importState = .loaded(.empty)
            return
        }

        Task.detached {
            self.importState = .loading
            let result = await self.importVideo(from: self.media)
            self.importState = .loaded(result)
        }
        
        main()
    }
    
    private func importVideo(from selection: PhotosPickerItem) async -> ImportedMedia {
        if selection.supportedContentTypes.contains(.jpeg) {
            let (image, url) = await mediaImporter.loadImage(from: selection)
            
            if let image, let url {
                return .image(image, url)
            }
        } else {
            // is saved in DB during loading
            if let videoModel = await mediaImporter.loadVideo(from: selection) {
                return .video(videoModel)
            }
        }
        
        return .empty
    }
}

// MARK: - Enums

extension MediaImportOperation {
    public enum ImportedMedia {
        case video(VideoModel)
        case image(UIImage, URL)
        case empty
    }
    
    public enum ImportState {
        case loading
        case loaded(ImportedMedia)
        case idle
        
        fileprivate var isExecuting: Bool {
            if case .loading = self {
                return true
            }
            
            return false
        }
        
        fileprivate var isFinished: Bool {
            if case .loaded = self {
                return true
            }
            
            return false
        }
        
        fileprivate var keyPath: String {
            switch self {
            case .idle:
                return "isReady"
            case .loading:
                return "isExecuting"
            case .loaded:
                return "isFinished"
            }
        }
    }
}
