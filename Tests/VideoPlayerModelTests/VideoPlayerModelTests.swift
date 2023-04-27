import XCTest
@testable import VideoPlayerModel

final class VideoPlayerModelTests: XCTestCase {
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(VideoPlayerModel().text, "Hello, World!")
        
        deleteAllVideos()
        addNewVideo()
        addNewVideo()
        checkForNumberOfVideos(2)
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
}
