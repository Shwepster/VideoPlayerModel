//
//  AVPlayerExtensions.swift
//  VideoPlayer
//
//  Created by Maxim Vynnyk on 06.04.2023.
//

import AVKit

public extension AVPlayer {
    var isPlaying: Bool {
        rate != 0 && error == nil
    }
}
