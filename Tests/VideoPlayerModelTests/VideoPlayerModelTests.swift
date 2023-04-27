import XCTest
@testable import VideoPlayerModel

final class VideoPlayerModelTests: XCTestCase {
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(VideoPlayerModel().text, "Hello, World!")
        
        let storage = AppServices.storage
        print(storage.getVideos())

        let video = VideoModel(id: UUID().uuidString, title: "Test", videoURL: URL.getPath(for: "test.MOV"))
        storage.saveVideo(video)
        
        print(storage.getVideos())
    }
}
