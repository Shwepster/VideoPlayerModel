import XCTest
@testable import VideoPlayerModel

final class VideoPlayerModelTests: XCTestCase {
    func testExample() throws {
        deleteAllVideos()
        addNewVideo()
        addNewVideo()
        checkForNumberOfVideos(2)
        checkMockups()
    }
    
    private func deleteAllVideos() {
        let storage = AppServices.storage
        let allVideos = storage.getVideos()
        allVideos.forEach(storage.deleteVideo)
        XCTAssertTrue(storage.getVideos().isEmpty)
    }
    
    private func addNewVideo() {
        let storage = AppServices.storage
        let previousCount = storage.getVideos().count
        
        let video = VideoModel(
            id: UUID().uuidString,
            title: "Test",
            videoURL: URL.getPath(for: "test.MOV")
        )
        
        // Add video
        storage.saveVideo(video)
        
        // Check if added
        checkForNumberOfVideos(previousCount + 1)
    }
    
    private func checkForNumberOfVideos(_ number: Int) {
        XCTAssertEqual(AppServices.storage.getVideos().count, number)
    }
    
    private func checkMockups() {
        Mockups.player
        Mockups.image
    }
}
