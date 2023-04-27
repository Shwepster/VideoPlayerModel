//
//  Double+TimeString.swift
//  Model
//
//  Created by Maxim Vynnyk on 25.04.2023.
//

import Foundation

extension Double {
    public func toTimeString() -> String {
        let timeInterval = Int(self)
        let seconds = timeInterval % 60
        let minutes = (timeInterval / 60) % 60
        let hours = timeInterval / 3600
        
        let formattedString = hours > 0
        ? String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        : String(format: "%02d:%02d", minutes, seconds)
        
        return formattedString
    }
}
