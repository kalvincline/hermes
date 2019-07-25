//
//  Drawer.swift
//  hermes
//
//  Created by Aidan Cline on 6/16/19.
//  Copyright © 2019 Aidan Cline. All rights reserved.
//

import UIKit
import AVKit
import MediaPlayer

class Drawer: UIView {
    
    let panGesture = UIPanGestureRecognizer()
    
    let indicator = UIView()
    let backgroundView = UIVisualEffectView()
    let backgroundGradientView = UIGradientView()
    let videoView = AVPlayerView()
    let videoPlayer = VideoPlayer()
    
    let contents = GroupScrollView()
    
    let smallContentView = UIView()
    let smallTitle = UILabel()
    let pausePlayButton = UIButton()
    
    var channelView = ChannelView()
    var suggestedVideosLabel = UILabel()
    
    var aspectRatio: CGFloat = 16/9 {
        didSet {
            if aspectRatio == 0 {
                aspectRatio = 16/9
            }
        }
    }
    
    var videoFrame: CGRect {
        return videoView.playerView.playerLayer.videoRect
    }
    
    var didPan: ((CGFloat) -> Void) = { _ in }
    var didEndPanning = {}
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        backgroundView.layer.cornerRadius = 10
        backgroundView.clipsToBounds = true
        
        indicator.layer.cornerRadius = 2.5
        indicator.clipsToBounds = true
        
        addSubview(backgroundView)
        backgroundView.contentView.addSubview(smallContentView)
        
        smallContentView.addSubview(smallTitle)
        smallContentView.addSubview(pausePlayButton)
        
        backgroundView.contentView.addSubview(backgroundGradientView)
        backgroundView.contentView.addSubview(indicator)
        backgroundView.contentView.addSubview(contents)
        
        if settings.experimentalPlayer {
            backgroundView.contentView.addSubview(videoPlayer)
        } else {
            backgroundView.contentView.addSubview(videoView)
        }
        
        backgroundView.addGestureRecognizer(panGesture)
        panGesture.isEnabled = true
        panGesture.addTarget(self, action: #selector(viewWasDragged(_:)))
        panGesture.cancelsTouchesInView = false
        
        smallTitle.numberOfLines = 2
        smallTitle.font = .systemFont(ofSize: 16, weight: .bold)
        
        updateTheme(animated: false)
        
        NotificationCenter.default.addObserver(forName: .themeChanged, object: nil, queue: .main) { (notification) in
            self.updateTheme(animated: true)
        }
        
        NotificationCenter.default.addObserver(forName: .videoOpened, object: nil, queue: .main) { (notification) in
            self.smallTitle.text = currentVideo?.title
            self.videoView.player = nil
            
            self.videoPlayer.pause()
            self.videoPlayer.player = nil
            self.videoPlayer.audioPlayer = nil
            
            self.contents.removeAllSubviews()
            
            let title = UILabel(frame: CGRect(x: 32, y: 0, width: self.contents.frame.width - 64, height: 40))
            title.numberOfLines = 0
            title.font = .systemFont(ofSize: 18, weight: .bold)
            title.text = currentVideo?.title
            title.sizeToFit()
            title.frame.size.width = self.contents.frame.width - 64
            
            let channel = InvidiousChannel(identifier: currentVideo?.channelID)
            channel.title = currentVideo?.channelTitle
            channel.thumbnails = currentVideo?.channelThumbnails
            channel.subscribers = currentVideo?.channelSubCount
            self.channelView = ChannelView(frame: CGRect(x: 0, y: 0, width: self.contents.frame.width, height: 0), channel: channel)
            
            self.suggestedVideosLabel = UILabel(frame: CGRect(x: 24, y: 0, width: self.contents.frame.width - 48, height: 20))
            self.suggestedVideosLabel.font = .systemFont(ofSize: 18, weight: .bold)
            self.suggestedVideosLabel.text = "Suggested videos"
            
            self.contents.addGap(height: 16)
            self.contents.addSubview(title)
            self.contents.addGap(height: 16)
            self.contents.addSubview(self.channelView)
            self.contents.addGap(height: 16)
            self.contents.addSubview(self.suggestedVideosLabel)
            self.contents.addGap(height: 16)
            self.getSuggestedVideos()
            
            let video = InvidiousVideo(identifier: currentVideo?.identifier)
            video.getData(fields: [.streamURLs, .videoURLs]) {
                let url1080p60 = video.streamURLs?.quality1080p60
                let url1080p = video.streamURLs?.quality1080p
                let url720p60 = video.streamURLs?.quality720p60
                let url720p = video.streamURLs?.quality720p
                let url480p = video.streamURLs?.quality480p
                let url360p = video.streamURLs?.quality360p
                let url240p = video.streamURLs?.quality240p
                let url144p = video.streamURLs?.quality144p
                
                var urlString = url720p ?? url480p ?? url360p ?? url240p ?? url144p
                
                switch settings.preferredQuality {
                case .auto:
                    if settings.experimentalPlayer {
                        urlString = url1080p60 ?? url1080p ?? url720p60 ?? urlString
                    }
                case .highest:
                    if settings.experimentalPlayer {
                        urlString = url1080p60 ?? url1080p ?? url720p60 ?? urlString
                    }
                case .q1080p60:
                    if settings.experimentalPlayer {
                        urlString = url1080p60 ?? url1080p ?? url720p60 ?? urlString
                    }
                case .q1080p:
                    if settings.experimentalPlayer {
                        urlString = url1080p ?? url720p60 ?? urlString
                    }
                case .q720p60:
                    if settings.experimentalPlayer {
                        urlString = url720p60 ?? urlString
                    }
                case .q720p:
                    urlString = url720p ?? url480p ?? url360p ?? url240p ?? url144p
                case .q480p:
                    urlString = url480p ?? url360p ?? url240p ?? url144p
                case .q360p:
                    urlString = url360p ?? url240p ?? url144p
                case .q240p:
                    urlString = url240p ?? url144p
                case .q144p:
                    urlString = url144p
                }
                
                if settings.experimentalPlayer {
                    if let url = URL(string: urlString ?? "") {
                        var audioPlayer: AVPlayer?
                        if let audioURL = URL(string: video.streamURLs?.audioOnly ?? "") {
                            audioPlayer = AVPlayer(url: audioURL)
                            self.videoPlayer.audioPlayer = audioPlayer
                        }
                        let player = AVPlayer(url: url)
                        self.videoPlayer.player = player
                        self.videoPlayer.frame = self.videoView.frame
                        if urlString == url1080p60 || urlString == url1080p || urlString == url720p60 {
                            self.videoPlayer.duration = CGFloat((self.videoPlayer.player?.currentItem?.duration.seconds ?? 0) / 2)
                        }
                        self.videoPlayer.play()
                    }
                } else {
                    let url720p = video.videoURLs?.quality720p
                    let url480p = video.videoURLs?.quality480p
                    let url360p = video.videoURLs?.quality360p
                    let url240p = video.videoURLs?.quality240p
                    let url144p = video.videoURLs?.quality144p
                    let urlString = url720p ?? url480p ?? url360p ?? url240p ?? url144p
                    if let url = URL(string: urlString ?? "") {
                        let player = AVPlayer(url: url)
                        self.videoView.player = player
                    }
                }
            }
            
            self.videoView.playerViewController.updatesNowPlayingInfoCenter = false
            MPNowPlayingCenter.title = currentVideo?.title
            MPNowPlayingCenter.artist = channel.title
            MPNowPlayingCenter.isExplicit = currentVideo?.ageRestricted
            MPNowPlayingCenter.duration = self.videoView.player?.currentItem?.duration
            MPNowPlayingCenter.elapsedTime = self.videoView.player?.currentTime()
            
            MPNowPlayingCenter.addPauseAction { (event) -> MPRemoteCommandHandlerStatus in
                self.videoView.pause()
                return self.videoView.rate == 0 ? .success : .commandFailed
            }
            
            MPNowPlayingCenter.addPlayAction { (event) -> MPRemoteCommandHandlerStatus in
                self.videoView.play()
                return self.videoView.rate == 1 ? .success : .commandFailed
            }
            
            MPNowPlayingCenter.addPrevAction { (event) -> MPRemoteCommandHandlerStatus in
                self.videoView.seek(to: .zero)
                return self.videoView.player?.currentTime() == .zero ? .success : .commandFailed
            }
            
            if let thumbnailURL = currentVideo?.thumbnails?.low {
                let url = URL(string: thumbnailURL)!
                URLDataHandler.downloadImage(url: url, { (image) in
                    MPNowPlayingCenter.artwork = image
                })
            }
            
        }
        
        NotificationCenter.default.addObserver(forName: .changeDrawer, object: nil, queue: .main) { (notification) in
            UIView.animate(withDuration: 0.375, delay: 0, usingSpringWithDamping: 0.75, initialSpringVelocity: 2, options: .curveEaseOut, animations: {
                self.didEndPanning()
                switch drawerState {
                case .fullscreen:
                    self.frame.origin.y = 0
                    self.backgroundView.frame.origin.y = safeArea.top + 20
                    self.indicator.frame = CGRect(x: self.frame.width / 2 - 20, y: (40 - 5)/2, width: 40, height: 5)
                    self.videoView.setFrameAnimated(CGRect(x: 0, y: 40, width: self.frame.width, height: self.frame.width / self.aspectRatio), withDuration: 0.25)
                    self.videoPlayer.frame = CGRect(x: 0, y: 40, width: self.frame.width, height: self.frame.width / self.aspectRatio)
                    self.smallContentView.frame.origin.y = self.videoView.frame.origin.y
                    self.backgroundGradientView.alpha = 1
                    self.contents.frame.origin.y = self.videoView.frame.maxY
                    self.contents.alpha = 1
                    interface.setStatusBarAnimated(.light)
                case .small:
                    self.frame.origin.y = self.frame.height - safeArea.bottom - 50 - 80
                    self.backgroundView.frame.origin.y = 0
                    self.indicator.frame = CGRect(x: self.frame.width / 2 - 20, y: (20 - 5)/2, width: 40, height: 5)
                    self.videoView.setFrameAnimated(CGRect(x: 0, y: 20, width: 60 * self.aspectRatio, height: 60), withDuration: 0.25)
                    self.videoPlayer.frame = CGRect(x: 0, y: 20, width: 60 * self.aspectRatio, height: 60)
                    self.smallContentView.frame.origin.y = self.videoView.frame.origin.y
                    self.backgroundGradientView.alpha = 0
                    self.contents.frame.origin.y = self.videoView.frame.maxY
                    self.contents.alpha = 0
                    NotificationCenter.default.post(name: .updateStatusBar, object: nil)
                case .closed:
                    self.frame.origin.y = self.frame.height
                    self.backgroundView.frame.origin.y = 0
                    self.videoView.player?.pause()
                    self.videoView.player = nil
                    self.contents.alpha = 0
                    self.videoPlayer.pause()
                    self.videoPlayer.player = nil
                    self.videoPlayer.audioPlayer = nil
                    UIHapticFeedback.generate(style: .selection)
                    NotificationCenter.default.post(name: .updateStatusBar, object: nil)
                }
            }, completion: nil)
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func layoutSubviews() {
        backgroundView.frame = CGRect(x: 0, y: (drawerState == .fullscreen) ? safeArea.top + 20 : 0, width: frame.width, height: frame.height + safeArea.top + 40)
        backgroundGradientView.frame = backgroundView.bounds
        smallContentView.frame = CGRect(x: 0, y: 20, width: frame.width, height: 60)
        smallTitle.frame = CGRect(x: 60 * aspectRatio + 16, y: (60 - 40)/2, width: smallContentView.frame.width - 16 - 16 - 60 * aspectRatio, height: 40)
        contents.frame.size = CGSize(width: frame.width, height: backgroundView.frame.height - contents.frame.origin.y - 40 - safeArea.top - 40)
        contents.contentInset.bottom = safeArea.bottom
    }
    
    func getSuggestedVideos() {
        let video = InvidiousVideo(identifier: currentVideo?.identifier)
        var videoViews: [UIView] = []
        for _ in 0..<10 {
            let view = SmallVideoView(frame: CGRect(x: 0, y: 0, width: contents.frame.width, height: 0))
            view.isIndividual = false
            view.showChannel = true
            videoViews.append(view)
            contents.addSubview(view)
            
            let gap = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 4))
            videoViews.append(gap)
            contents.addSubview(gap)
        }
        video.getData(fields: [.relatedVideos]) {
            if let videos = video.recommendedVideos {
                if videos.count > 0 {
                    for view in videoViews {
                        self.contents.removeSubview(view)
                    }
                    
                    videoViews = []
                    for video in videos[0...9] {
                        let view = SmallVideoView(frame: CGRect(x: 0, y: 0, width: self.contents.frame.width, height: 4))
                        view.isIndividual = false
                        view.showChannel = true
                        view.video = video
                        self.contents.addSubview(view)
                        self.contents.addGap(height: 4)
                    }
                    self.contents.addGap(height: 4)
                }
            }
        }
    }
    
    @objc func viewWasDragged(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: self).y
        switch sender.state {
        case .changed:
            setTranslation(translation)
        case .ended:
            if drawerState == .fullscreen {
                if translation >= 100 {
                    if frame.origin.y > frame.height - safeArea.bottom - 50 - 80 {
                        drawerState = .closed
                    } else {
                        drawerState = .small
                    }
                } else {
                    drawerState = .fullscreen
                }
            } else {
                if translation <= -30 {
                    drawerState = .fullscreen
                } else if translation >= 20 {
                    drawerState = .closed
                } else {
                    drawerState = .small
                }
            }
        default: ()
        }
    }
    
    func setTranslation(_ offset: CGFloat) {
        if drawerState == .fullscreen {
            var translation = limit(offset, min: -10)
            if translation < 0 {
                translation /= 5
            }
            didPan(translation)
            let transition = translation / 100
            backgroundGradientView.alpha = 1 - transition/4
            frame.origin.y = translation
            
            var videoFrame = CGRect()
            videoFrame.origin.y = limit(40 - translation/2, min: 20, max: 40)
            videoFrame.size.width = limit(frame.width - translation/1.5, min: 60 * aspectRatio, max: frame.width)
            videoFrame.size.height = videoFrame.width / aspectRatio
            videoView.setFrame(videoFrame)
            videoPlayer.frame = videoFrame
            indicator.frame.origin.y = (videoFrame.origin.y - indicator.frame.height)/2
            smallContentView.frame.origin.y = videoView.frame.origin.y
            contents.frame.origin.y = videoView.frame.maxY
            contents.alpha = 1 - translation/200
        } else if drawerState == .small {
            var translation = offset
            if frame.origin.y < safeArea.top + 20 {
                let difference = frame.height - 50 - 80 - safeArea.bottom - safeArea.top - 20
                translation = -(difference + abs(translation + difference)/5)
            }
            didPan(translation)
            let transition = translation / -30
            backgroundGradientView.alpha = transition/4
            frame.origin.y = frame.height - 50 - 80 + translation
            
            var videoFrame = CGRect()
            videoFrame.origin.y = limit(20 - translation/2, min: 20, max: 40)
            videoFrame.size.height = limit(60 - translation/2, min: 60, max: frame.width / aspectRatio)
            videoFrame.size.width = videoFrame.height * aspectRatio
            videoView.setFrame(videoFrame)
            videoPlayer.frame = videoFrame
            indicator.frame.origin.y = (videoFrame.origin.y - indicator.frame.height)/2
            smallContentView.frame.origin.y = videoView.frame.origin.y
            contents.frame.origin.y = videoView.frame.maxY
            contents.alpha = -translation/300
        } else if drawerState == .closed {
            frame.origin.y = frame.height
        }
    }
    
    func updateTheme(animated: Bool) {
        UIView.animate(withDuration: animated ? 0.25 : 0) {
            self.setThemes()
        }
    }
    
    func setThemes() {
        indicator.backgroundColor = interface.textColor.withAlphaComponent(1/3)
        backgroundView.effect = interface.blurEffect
        suggestedVideosLabel.textColor = interface.textColor
        backgroundGradientView.colors = [interface.contentColor.cgColor, interface.backgroundColor.withAlphaComponent(interface.style == .black ? 1 : 0).cgColor]
        backgroundView.contentView.backgroundColor = interface.style == .light ? .clear : interface.blurEffectBackground
    }
    
}

class MPNowPlayingCenter {
    
    static var title: String? {
        didSet {
            update()
        }
    }
    
    static var artist: String? {
        didSet {
            update()
        }
    }
    
    static var album: String? {
        didSet {
            update()
        }
    }
    
    static var artwork: UIImage? {
        didSet {
            update()
        }
    }
    
    static var genre: String? {
        didSet {
            update()
        }
    }
    
    static var isExplicit: Bool? {
        didSet {
            update()
        }
    }
    
    static var duration: CMTime? {
        didSet {
            update()
        }
    }
    
    static var elapsedTime: CMTime? {
        didSet {
            update()
        }
    }
    
    static var playbackRate: Float? {
        didSet {
            update()
        }
    }
    
    static func update() {
        MPNowPlayingInfoCenter.default().nowPlayingInfo = [
            MPMediaItemPropertyTitle: title ?? "",
            MPMediaItemPropertyArtist: artist ?? "",
            MPMediaItemPropertyAlbumTitle: album ?? "",
            MPMediaItemPropertyGenre: genre ?? "",
            MPMediaItemPropertyPlaybackDuration: duration?.seconds ?? 0,
            MPNowPlayingInfoPropertyElapsedPlaybackTime: elapsedTime?.seconds ?? 0,
            MPNowPlayingInfoPropertyPlaybackRate: playbackRate ?? 0,
            MPMediaItemPropertyIsExplicit: isExplicit ?? false
        ]
        
        if let artwork = artwork {
            let artworkItem = MPMediaItemArtwork(boundsSize: artwork.size) { (size) -> UIImage in
                return artwork
            }
            MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPMediaItemPropertyArtwork] = artworkItem
        }
    }
    
    static func addPauseAction(_ block: @escaping (MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus) {
        UIApplication.shared.beginReceivingRemoteControlEvents()
        MPRemoteCommandCenter.shared().pauseCommand.addTarget(handler: block)
    }
    
    static func addPlayAction(_ block: @escaping (MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus) {
        UIApplication.shared.beginReceivingRemoteControlEvents()
        MPRemoteCommandCenter.shared().playCommand.addTarget(handler: block)
    }
    
    static func addNextAction(_ block: @escaping (MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus) {
        UIApplication.shared.beginReceivingRemoteControlEvents()
        MPRemoteCommandCenter.shared().nextTrackCommand.addTarget(handler: block)
    }
    
    static func addPrevAction(_ block: @escaping (MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus) {
        UIApplication.shared.beginReceivingRemoteControlEvents()
        MPRemoteCommandCenter.shared().previousTrackCommand.addTarget(handler: block)
    }
    
}
