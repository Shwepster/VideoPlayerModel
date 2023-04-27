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
        queue.maxConcurrentOperationCount = 4
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
        let operations = mediaSelection.map {
            MediaImportOperation(media: $0, mediaImporter: mediaImporter)
        }
        
        self.mediaSelection.removeAll()
        
        // Create subscribers for import state
        operations.forEach { operation in
            runningImports[operation.id] = operation.importState.value
            
            operation.importState
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { [weak self] _ in
                    // Remove when import is finished
                    self?.runningImports.removeValue(forKey: operation.id)
                }, receiveValue: { [weak self] state in
                    self?.runningImports[operation.id] = state
                })
                .store(in: &subscriptions)
        }
        
        operationQueue.addOperations(operations, waitUntilFinished: false)
    }
}
