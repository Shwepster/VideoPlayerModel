//
//  StorageService.swift
//  VideoPlayer
//
//  Created by Maxim Vynnyk on 05.04.2023.
//

import CoreData
import Combine

public final class StorageService {
    public static let shared = StorageService()
    public let updatesPublisher: AnyPublisher<Bool, Never>
    private let fileManager = FileManager.default
    
    private lazy var persistentContainer: PersistentContainer = {
        let databaseName = "Database"
        guard let modelURL = Bundle.module.url(forResource: databaseName, withExtension: "momd") else {
            fatalError("Error loading mom from bundle")
        }
        
        guard let mom = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Error initializing mom from: \(modelURL)")
        }

        let container = PersistentContainer(name: databaseName, managedObjectModel: mom)
        container.setup()
        return container
    }()
    
    private init() {
        updatesPublisher = NotificationCenter.default
            .publisher(for: .NSManagedObjectContextDidSave)
            .map { _ in true }
            .eraseToAnyPublisher()
    }
    
    public func getVideos() -> [VideoModel] {
        let models: [VideoCDM] = persistentContainer.getObjects() ?? []
        return models.map(VideoModel.init)
    }
    
    public func getVideo(for id: String) -> VideoModel? {
        let model: VideoCDM? = persistentContainer.getObject(predicate: VideoCDM.objectPredicate(id: id))
        return model.map(VideoModel.init)
    }
    
    public func saveVideo(_ video: VideoModel) {
        persistentContainer.createObject(type: VideoCDM.self, data: video)
    }
    
    public func deleteVideo(_ video: VideoModel) {
        persistentContainer.deleteObjects(
            of: VideoCDM.self,
            predicate: VideoCDM.objectPredicate(id: video.id)
        )
        
        do {
            try fileManager.removeItem(at: video.videoURL)
            guard let imageURL = video.imageURL else { return }
            try fileManager.removeItem(at: imageURL )
        } catch {}
    }
}
