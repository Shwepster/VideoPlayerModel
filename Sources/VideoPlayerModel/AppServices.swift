//
//  AppServices.swift
//  VideoPlayer
//
//  Created by Maxim Vynnyk on 17.04.2023.
//

import Foundation

public enum AppServices {
    public static func createVideoImporter() -> MediaImporterProtocol {
        let mediaImporter = MediaImporter()
        let previewDecorator = MediaImporterPreviewDecorator(mediaImporter: mediaImporter)
        let loggerImporter = MediaImporterLoggingProxy(mediaImporter: previewDecorator, logger: logger)
        return loggerImporter
    }
    
    public static func createImageImporter() -> MediaImporterProtocol {
        let mediaImporter = MediaImporter()
        let loggerImporter = MediaImporterLoggingProxy(mediaImporter: mediaImporter, logger: logger)
        return loggerImporter
    }
    
    public static var logger: Logger = BaseLogger()
    
    public static var storage: StorageService { .shared }
}
