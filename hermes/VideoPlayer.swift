//
//  VideoPlayer.swift
//  hermes
//
//  Created by Aidan Cline on 6/24/19.
//  Copyright © 2019 Aidan Cline. All rights reserved.
//

import UIKit
import AVKit

class VideoPlayer: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        //layer.addSublayer(playerLayer)
        layer.addSublayer(audioPlayerLayer)
        addSubview(videoView)
        addSubview(contentView)
        addSubview(controlsView)
        controlsView.addSubview(loadingIndicator)
        loadingIndicator.startAnimating()
        backgroundColor = .black
    }
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    convenience init(frame: CGRect, player: AVPlayer?, audioPlayer: AVPlayer?) {
        self.init(frame: frame)
        self.player = player
        self.audioPlayer = player
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //playerLayer.frame = bounds
        videoView.frame = bounds
        audioPlayerLayer.frame = .zero
        contentView.frame = bounds
        controlsView.frame = bounds
        loadingIndicator.frame = bounds
    }
    
    ///The view that displays videos, with a container `AVPlayerLayer`.
    let videoView = AVPlayerLayerView()
    ///The layer that displays `avplayer`.
    //let playerLayer = AVPlayerLayer()
    private let audioPlayerLayer = AVPlayerLayer()
    
    ///The view between `playerLayer` and `controlsView`, for adding extra content on top of the video.
    let contentView = UIView()
    ///The view containing controls for the video.
    let controlsView = UIView()
    
    let loadingIndicator = UIActivityIndicatorView()
    
    ///The visual player.
    var player: AVPlayer? {
        get {
            //return playerLayer.player
            return videoView.playerLayer.player
        }
        set {
            newValue?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 60), queue: .main, using: { (currentTime) in
                if self.player?.timeControlStatus == .playing && self.player?.currentItem?.isPlaybackLikelyToKeepUp ?? false {
                    if self.audioPlayer?.rate == 0 {
                        self.audioPlayer?.play()
                        self.audioPlayer?.seek(to: CMTime(seconds: currentTime.seconds - 1, preferredTimescale: currentTime.timescale))
                        if self.loadingIndicator.alpha > 0 {
                            UIView.animate(withDuration: 0.25) {
                                self.loadingIndicator.transform = .init(scaleX: 0.001, y: 0.001)
                                self.loadingIndicator.alpha = 0
                            }
                        }
                    }
                } else {
                    self.audioPlayer?.pause()
                    if self.loadingIndicator.alpha < 1 {
                        UIView.animate(withDuration: 0.25) {
                            self.loadingIndicator.transform = .init(scaleX: 1, y: 1)
                            self.loadingIndicator.alpha = 1
                        }
                    }
                }
                if CGFloat(self.player?.currentTime().seconds ?? 0) >= self.duration {
                    self.pause()
                }
            })
            //playerLayer.player = newValue
            self.videoView.playerLayer.player = newValue
            duration = CGFloat(newValue?.currentItem?.duration.seconds ?? 0)
        }
    }
    
    ///The audio player. Only set this if the main player has no audio.
    var audioPlayer: AVPlayer? {
        get {
            return audioPlayerLayer.player
        }
        set {
            audioPlayerLayer.player = newValue
            player?.isMuted = (newValue != nil)
        }
    }
    
    var videoFrame: CGRect? {
        //return playerLayer.videoRect
        return videoView.playerLayer.videoRect
    }
    
    ///Determines whether or not controls are displayed.
    var showControls = true {
        didSet {
            controlsView.alpha = 0
        }
    }
    
    ///The duration of the video. By default, it is set to the length of `player`, but it's customizable by the developer.
    var duration: CGFloat = 0
    
    ///Pauses the video.
    func pause() {
        player?.pause()
        audioPlayer?.pause()
        for action in pauseActions {
            action(player?.currentItem?.currentTime())
        }
    }
    
    ///Resumes the video.
    func play() {
        player?.play()
        audioPlayer?.play()
        for action in playActions {
            action(player?.currentItem?.currentTime())
        }
    }
    
    private var pauseActions: [(CMTime?) -> Void] = []
    func addPauseAction(_ action: @escaping (CMTime?) -> Void) {
        pauseActions.append(action)
    }
    
    private var playActions: [(CMTime?) -> Void] = []
    func addPlayAction(_ action: @escaping (CMTime?) -> Void) {
        playActions.append(action)
    }
    
}
