//
//  MediaImportService.swift
//  Model
//
//  Created by Maxim Vynnyk on 26.04.2023.
//

import Foundation
import _PhotosUI_SwiftUI
import Combine

public final class MediaImportService: ObservableObject {
    private let mediaImporter: MediaImporterProtocol
    private let operationQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 10
        queue.qualityOfService = .background
        return queue
    }()
    
    private var subscriptions = Set<AnyCancellable>()
    @Published public var runningImports: [String: MediaImportOperation.ImportState] = [:]
    @Published public var mediaSelection: [PhotosPickerItem] = [] {
        didSet {
            if mediaSelection.isNotEmpty {
                startImporting(mediaSelection)
            }
        }
    }
    
    public init(mediaImporter: MediaImporterProtocol) {
        self.mediaImporter = mediaImporter
    }
    
    private func startImporting(_ mediaSelection: [PhotosPickerItem]) {
        self.mediaSelection.removeAll()
        
        let operations = mediaSelection.map {
            MediaImportOperation(media: $0, mediaImporter: mediaImporter)
        }
        
        // Create subscribers for import state
        operations.forEach { operation in
            let operationId = operation.id
            runningImports[operationId] = operation.importState
            
            operation.$importState
                .receive(on: DispatchQueue.main)
                .sink { [weak self] state in
                    self?.runningImports[operationId] = state
                    
                    if case .loaded = state {
                        self?.runningImports.removeValue(forKey: operationId)
                    }
                }
                .store(in: &subscriptions)
        }
        
        operationQueue.addOperations(operations, waitUntilFinished: false)
    }
}
