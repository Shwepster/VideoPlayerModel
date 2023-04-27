//
//  VideoPlayerEngine.swift
//  VideoPlayer
//
//  Created by Maxim Vynnyk on 11.04.2023.
//

import AVKit
import Combine

public final class VideoPlayerEngine: ObservableObject {
    @Published public var isPlaying = false {
        didSet {
            guard oldValue != isPlaying else { return }
            isPlaying ? play() : pause()
        }
    }
    
    @Published public var duration: CMTime? = nil
    @Published public var currentTime: Double = 0 {
        didSet {
            guard !isPlaying else { return }
            seek(to: currentTime)
        }
    }
    
    public private(set) var player: AVPlayer
    private var playObserver: NSKeyValueObservation?
    private var subscriptions = Set<AnyCancellable>()
    private var didEnd = false
    
    public init(asset: AVAsset) {
        let item = AVPlayerItem(asset: asset)
        player = AVPlayer(playerItem: item)
        player.actionAtItemEnd = .pause
        subscribeObservers()
        loadDuration()
    }
    
    deinit {
        playObserver?.invalidate()
    }
    
    private func play() {
        if didEnd {
            player.seek(to: .zero)
            didEnd = false
        }
        
        player.play()
    }
    
    private func pause() {
        player.pause()
    }
    
    public func seek(to time: Double) {
        let newTime = CMTime(
            seconds: time,
            preferredTimescale: duration?.timescale ?? 600
        )
        
        player.seek(
            to: newTime,
            toleranceBefore: .zero,
            toleranceAfter: .zero
        )
    }
    
    public func seek(appendingSeconds: Double) {
        let newTime = CMTime(
            seconds: currentTime + appendingSeconds,
            preferredTimescale: duration?.timescale ?? 600
        )
        
        player.seek(
            to: newTime,
            toleranceBefore: .zero,
            toleranceAfter: .zero
        )
    }
    
    public func subscribeOnProgress(
        forWidth width: CGFloat? = nil,
        updateFrequency: Double = 0.5
    ) -> AnyPublisher<Double, Never> {
        $duration
            .compactMap { $0 }
            .map { time in
                let updateSeconds: Double = {
                    if let width {
                        return updateFrequency * time.seconds / width
                    }
                    return updateFrequency
                }()
                
                return CMTime(seconds: updateSeconds, preferredTimescale: time.timescale)
            }
            .flatMap { [weak self] time in
                self.publisher
                    .flatMap { engine in
                        engine.player.periodicTimePublisher(forInterval: time)
                    }
            }
            .map(\.seconds)
            .eraseToAnyPublisher()
    }
    
    public func startTrackingProgress(
        forWidth width: CGFloat? = nil,
        updateFrequency: Double = 0.5
    ) {
        subscribeOnProgress(forWidth: width, updateFrequency: updateFrequency)
            .sink { [weak self] seconds in
                self?.currentTime = seconds
            }
            .store(in: &subscriptions)
    }
    
    // MARK: - Private

    private func loadDuration() {
        Task { [weak self] in
            let duration = try? await self?.player.currentItem?.asset.load(.duration)
            Task { @MainActor [weak self] in
                self?.duration = duration
            }
        }
    }
    
    private func subscribeObservers() {
        subscribeOnPlayChange()
        subscribeOnPlayEnd()
    }
    
    private func subscribeOnPlayChange() {
        playObserver = player.observe(\.rate, options: [.initial, .new]) { [weak self] player, value in
            Task { @MainActor [weak self] in
                self?.isPlaying = player.isPlaying
            }
        }
    }
    
    private func subscribeOnPlayEnd() {
        NotificationCenter.default
            .publisher(
                for: .AVPlayerItemDidPlayToEndTime,
                object: player.currentItem
            )
            .sink { [weak self] _ in
                self?.didEnd = true
            }
            .store(in: &subscriptions)
    }
}
