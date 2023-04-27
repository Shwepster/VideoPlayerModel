//
//  Event.swift
//  VideoPlayer
//
//  Created by Maxim Vynnyk on 16.04.2023.
//

import Foundation

public struct Event {
    var parameters: [AnyHashable: Any]
    var name: String
    
    public init(name: String, parameters: [AnyHashable: Any] = [:]) {
        self.parameters = parameters
        self.name = name
    }
}

extension Event {
    static func startImportingVideo() -> Self {
        .init(name: "Start importing video")
    }
    
    static func finishImportingVideo() -> Self {
        .init(name: "Finish importing video")
    }
    
    static func generatedPreview(path: String) -> Self {
        .init(name: "Generated preview", parameters: ["path": path])
    }
    
    static func videoImportedSuccess(videoPath: String) -> Self {
        .init(name: "Video imported success", parameters: ["path": videoPath])
    }
    
    static func startImportingImage() -> Self {
        .init(name: "Start importing image")
    }
    
    static func finishImportingImage() -> Self {
        .init(name: "Finish importing image")
    }
    
    static func imageImportedSuccess(path: String) -> Self {
        .init(name: "Image imported success", parameters: ["path": path])
    }
}
