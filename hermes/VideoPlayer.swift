//
//  VideoPlayer.swift
//  hermes
//
//  Created by Aidan Cline on 9/11/19.
//  Copyright © 2019 Aidan Cline. All rights reserved.
//

import UIKit
import AVKit

class VideoPlayer: UIView {
    
    let audioPlayerLayer = AVPlayerLayer()
    let contentView = UIView()
    let controlsView = UIView()
    
    let loadingIndicator = UIActivityIndicatorView(style: .large)
    
    var playerLayer: AVPlayerLayer {
        return self.layer as! AVPlayerLayer
    }
    
    override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
    
    convenience init(url: URL?, duration: Double?) {
        self.init(url: url, audioURL: nil, duration: duration)
    }
    
    convenience init(url: URL?, audioURL: URL?, duration: Double?) {
        self.init(frame: .zero)
        streamURL = url
        self.audioURL = audioURL
        self.duration = duration
    }
    
    convenience init() {
        self.init(url: nil, audioURL: nil, duration: nil)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(contentView)
        addSubview(controlsView)
        controlsView.addSubview(loadingIndicator)
        loadingIndicator.hidesWhenStopped = true
        
        let session = AVAudioSession()
        do {
            try session.setCategory(.playback)
        } catch {
            print("Failed to set audio cateogry to .playback")
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = bounds
        controlsView.frame = bounds
        loadingIndicator.frame = controlsView.bounds
    }
    
    var videoPlayer: AVPlayer? {
        get {
            return playerLayer.player
        }
        set {
            videoPlayer?.pause()
            playerLayer.player = newValue
            _ = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true, block: { (timer) in
                self.videoPlayer?.play()
                if self.videoPlayer?.currentTime().seconds ?? 0 <= self.duration ?? 0 {
                    if self.videoPlayer?.status == .readyToPlay && self.audioPlayer?.status == .readyToPlay {
                        self.loadingIndicator.stopAnimating()
                        if self.videoPlayer?.timeControlStatus == .playing {
                            self.audioPlayer?.play()
                        } else {
                            self.audioPlayer?.pause()
                        }
                    } else {
                        self.audioPlayer?.pause()
                        self.loadingIndicator.startAnimating()
                    }
                    
                    print("\(self.videoPlayer?.currentTime().seconds ?? 0.0) seconds")
                } else {
                    self.pause()
                }
            })
        }
    }
    
    var audioPlayer: AVPlayer? {
        get {
            return audioPlayerLayer.player
        }
        set {
            audioPlayer?.pause()
            audioPlayerLayer.player = newValue
        }
    }
    
    func stop() {
        pause()
        videoPlayer = nil
        audioPlayer = nil
    }
    
    func pause() {
        videoPlayer?.pause()
        audioPlayer?.pause()
        rate = 0
    }
    
    func play() {
        videoPlayer?.play()
        audioPlayer?.play()
        rate = 1
    }
    
    var streamURL: URL? {
        didSet {
            if let url = streamURL {
                videoPlayer = AVPlayer(url: url)
            } else {
                videoPlayer = nil
            }
        }
    }
    
    var audioURL: URL? {
        didSet {
            if let url = audioURL {
                audioPlayer = AVPlayer(url: url)
            } else {
                audioPlayer = nil
            }
        }
    }
    
    var duration: Double?
    var rate: Float = 1 {
        didSet {
            videoPlayer?.rate = rate
            audioPlayer?.rate = rate
        }
    }
    
}
