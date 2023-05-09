//
//  File.swift
//  
//
//  Created by Maxim Vynnyk on 09.05.2023.
//

import Foundation

extension Error {
    var nsError: NSError {
        self as NSError
    }
}
