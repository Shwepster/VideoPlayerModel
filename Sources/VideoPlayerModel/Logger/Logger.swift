//
//  Logger.swift
//  VideoPlayer
//
//  Created by Maxim Vynnyk on 16.04.2023.
//

import Foundation

public protocol Logger {
    var isEnabled: Bool { get set }
    func log(event: Event)
}

public final class BaseLogger: Logger {
    public var isEnabled: Bool = true
    public init() {}
    
    public func log(event: Event) {
        guard isEnabled else { return }
        
        if event.parameters.isEmpty {
            NSLog("%@", event.name)
        } else {
            NSLog("%@\nParameters:\n%@", event.name, event.parameters)
        }
    }
}
