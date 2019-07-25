//
//  VideoView.swift
//  hermes
//
//  Created by Aidan Cline on 4/10/19.
//  Copyright © 2019 Aidan Cline. All rights reserved.
//

import UIKit
import AVKit
import MediaPlayer

extension UIView {
    var viewController: UIViewController? {
        if let nextResponder = self.next as? UIViewController {
            return nextResponder
        } else if let nextResponder = self.next as? UIView {
            return nextResponder.viewController
        } else {
            return nil
        }
    }
}

class AVPlayerView: UIView {

    let playerViewController = AVPlayerViewController()
    
    let playerView = AVPlayerLayerView()
    private var playerResume: AVPlayer?
    
    var player: AVPlayer? {
        get {
            return playerViewController.player
        }
        set {
            if newValue == nil {
                MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
                UIApplication.shared.endReceivingRemoteControlEvents()
            }
            player?.pause()
            playerViewController.player = newValue
            playerView.playerLayer.player = newValue
            player?.play()
        }
    }
    
    func pause() {
        player?.pause()
    }
    
    func play() {
        player?.play()
    }
    
    func seek(to time: CMTime) {
        player?.seek(to: time)
    }
    
    var rate: Float {
        return player?.rate ?? 0
    }
    
    convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        playerView.backgroundColor = .black
        playerView.playerLayer.videoGravity = .resizeAspect
        playerViewController.exitsFullScreenWhenPlaybackEnds = true
        
        addSubview(playerViewController.view)
        addSubview(playerView)
        
        NotificationCenter.default.addObserver(forName: .enteredBackground, object: nil, queue: .main) { (notification) in
            if ApplicationSettings().backgroundPlay {
                self.playerResume = self.player
                self.playerViewController.player = nil
                self.playerView.playerLayer.player = nil
            }
        }
        NotificationCenter.default.addObserver(forName: .enteredForeground, object: nil, queue: .main) { (notification) in
            if ApplicationSettings().backgroundPlay {
                self.player = self.playerResume
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    var videoRect: CGRect {
        return playerView.playerLayer.videoRect
    }
    
    var aspectRatio: CGFloat {
        if videoRect.height > 0 {
            return videoRect.width / videoRect.height
        } else {
            return 16/9
        }
    }
    
    func setFrame(_ frame: CGRect) {
        self.frame = frame
        playerViewController.view.frame = bounds
        playerView.frame = bounds
    }
    
    func setFrameAnimated(_ frame: CGRect, withDuration duration: TimeInterval) {
        setFrame(self.frame)
        playerViewController.view.isHidden = true
        playerView.isHidden = false
        UIView.animate(withDuration: duration, animations: {
            self.setFrame(frame)
        }) { (complete) in
            self.playerViewController.view.isHidden = false
            self.playerView.isHidden = true
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerViewController.view.frame = bounds
    }
}

class AVPlayerLayerView: UIView {
    override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
    
    var playerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer
    }
}
