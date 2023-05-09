import XCTest
@testable import VideoPlayerModel

final class VideoPlayerModelTests: XCTestCase {
    func testExample() async throws {
        checkMockups()
        await deleteAllVideos()
        await addNewVideo()
        await addNewVideo()
        await checkForNumberOfVideos(2)
        
        // Concurrency
        testConcurrentAdding(number: 100)
        try await Task.sleep(for: .seconds(2))
        await checkForNumberOfVideos(102)
    }
    
    private func deleteAllVideos() async {
        let storage = AppServices.storage
        let allVideos = await storage.getVideos()
        for video in allVideos {
            await storage.deleteVideoAsync(video)
        }
        
        let videos = await storage.getVideos()
        XCTAssertTrue(videos.isEmpty)
    }
    
    private func addNewVideo() async {
        let storage = AppServices.storage
//        let previousCount = await storage.getVideos().count
        
        let video = VideoModel(
            id: UUID().uuidString,
            title: "Test",
            videoURL: URL.getPath(for: "test.MOV")
        )
        
        // Add video
        await storage.saveVideoAsync(video)
        
        // Check if added
//        await checkForNumberOfVideos(previousCount + 1)
    }
    
    private func checkForNumberOfVideos(_ number: Int) async {
        let videos = await AppServices.storage.getVideos()
        
        NSLog("Videos count: \(videos.count)")
        XCTAssertEqual(videos.count, number)
    }
    
    private func testConcurrentAdding(number: Int) {
        let storage = AppServices.storage
        
        for _ in 0..<number {
            Task.detached(priority: .medium) {
                await self.addNewVideo()
            }
        }
    }
    
    private func checkMockups() {
        Mockups.player
        Mockups.image
    }
}
