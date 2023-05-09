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

//        let container = PersistentContainerSynchronized(name: databaseName, managedObjectModel: mom)
        let container = PersistentContainerActor(name: databaseName, managedObjectModel: mom)
        container.setup()
        return container
    }()
    
    private init() {
        updatesPublisher = NotificationCenter.default
            .publisher(for: .NSManagedObjectContextDidSave)
            .map { _ in true }
            .eraseToAnyPublisher()
    }
    
    private func test() {
        Task {
            let center = NotificationCenter.default
            let notifications = center.notifications(named: .NSManagedObjectContextDidSave)
            
            let filteredNotifications = notifications.filter { notification in
                !notification.name.rawValue.isEmpty
            }
            
            for await notification in filteredNotifications {
                print("+++++++++++ \(notification.name)")
            }
        }
    }
    
    public func getVideos() async -> [VideoModel] {
        do {
            let models: [VideoCDM] = try await persistentContainer.getObjects(nil)
            return models.map(VideoModel.init)
        } catch {
            fatalError(error.nsError.localizedDescription)
        }
    }
    
    public func getVideo(for id: String) async -> VideoModel? {
        do {
            let model: VideoCDM? = try await persistentContainer.getObject(predicate: VideoCDM.objectPredicate(id: id))
            return model.map(VideoModel.init)
        } catch {
            fatalError(error.nsError.localizedDescription)
        }
    }
    
    @available(*, deprecated, message: "Use async version instead")
    public func saveVideo(_ video: VideoModel) {
        Task {
            await saveVideoAsync(video)
        }
    }
    
    public func saveVideoAsync(_ video: VideoModel) async {
        do {
            try await persistentContainer.saveObject(
                type: VideoCDM.self,
                data: video,
                predicate: VideoCDM.objectPredicate(id: video.id)
            )
        } catch {
            fatalError(error.nsError.localizedDescription)
        }
    }
    
    @available(*, deprecated, message: "Use async version instead")
    public func deleteVideo(_ video: VideoModel) {
        Task {
            await deleteVideoAsync(video)
        }
    }
    
    public func deleteVideoAsync(_ video: VideoModel) async {
        do {
            try await persistentContainer.deleteObjects(
                of: VideoCDM.self,
                predicate: VideoCDM.objectPredicate(id: video.id)
            )
            
            try fileManager.removeIfExists(at: video.videoURL)
            guard let imageURL = video.imageURL else { return }
            try fileManager.removeIfExists(at: imageURL )
        } catch {
            fatalError("Unresolved error \(error.nsError.localizedDescription), \(error.nsError.userInfo)")
        }
    }
}
