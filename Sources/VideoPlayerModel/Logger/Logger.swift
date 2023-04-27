//
//  Logger.swift
//  VideoPlayer
//
//  Created by Maxim Vynnyk on 16.04.2023.
//

import Foundation

public protocol Logger {
    func log(event: Event)
}

public final class BaseLogger: Logger {
    public init() {}
    
    public func log(event: Event) {
        if event.parameters.isEmpty {
            NSLog("%@", event.name)
        } else {
            NSLog("%@\nParameters:\n%@", event.name, event.parameters)
        }
    }
}
