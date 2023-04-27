//
//  AVAsset+Tumbnail.swift
//  VideoPlayer
//
//  Created by Maxim Vynnyk on 05.04.2023.
//

import AVKit

extension AVAsset {
    func generateThumbnail() async -> UIImage? {
        await withCheckedContinuation { continuation in
            DispatchQueue.global().async {
                let imageGenerator = AVAssetImageGenerator(asset: self)
                let time = CMTime(seconds: 0.0, preferredTimescale: 600)
                let times = [NSValue(time: time)]
                
                imageGenerator.generateCGImagesAsynchronously(forTimes: times) { _, image, _, _, _ in
                    if let image = image {
                        continuation.resume(returning: UIImage(cgImage: image))
                    } else {
                        continuation.resume(returning: nil)
                    }
                }
            }
        }
    }
}
