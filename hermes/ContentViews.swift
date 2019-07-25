//
//  ContentViews.swift
//  hermes
//
//  Created by Aidan Cline on 6/7/19.
//  Copyright © 2019 Aidan Cline. All rights reserved.
//

import UIKit
import PopMenu

class LargeVideoCell: UITableViewCell, UIContextMenuInteractionDelegate {
    
    @available(iOS 13.0, *) // context menus don't get added till ios 13
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil, actionProvider: { suggestedActions in
            return self.contextMenu()
        })
    }
    
    @available(iOS 13.0, *)
    func contextMenu() -> UIMenu {
        var actions: [UIAction] = []
        if settings.signedIn && video?.identifier != nil {
            if self.rating != .liked {
                actions.append(UIAction(__title: "Like", image: UIImage(systemName: "hand.thumbsup"), options: []) { action in
                    self.rating = .liked
                    YTVideo(identifier: self.video!.identifier!).setRating(.liked) {
                        self.getRating()
                    }
                })
            } else {
                actions.append(UIAction(__title: "Remove like", image: UIImage(systemName: "xmark"), options: []) { action in
                    self.rating = .noRating
                    YTVideo(identifier: self.video!.identifier!).setRating(.noRating) {
                        self.getRating()
                    }
                })
            }
            
            if self.rating != .disliked {
                actions.append(UIAction(__title: "Dislike", image: UIImage(systemName: "hand.thumbsdown"), options: []) { action in
                    self.rating = .disliked
                    YTVideo(identifier: self.video!.identifier!).setRating(.disliked) {
                        self.getRating()
                    }
                })
            } else {
                actions.append(UIAction(__title: "Remove dislike", image: UIImage(systemName: "xmark"), options: []) { action in
                    self.rating = .noRating
                    YTVideo(identifier: self.video!.identifier!).setRating(.noRating) {
                        self.getRating()
                    }
                })
            }
        }
        
        if let id = video?.identifier {
            actions.append(UIAction(__title: "Share", image: UIImage(systemName: "square.and.arrow.up"), options: []) { action in
                let url = URL(string: "https://www.youtube.com/watch?v=\(id)")!
                let shareSheetViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
                shareSheetViewController.popoverPresentationController?.sourceView = self
                shareSheetViewController.view.tintColor = interface.tintColor
                self.viewController?.present(shareSheetViewController, animated: true)
            })
        }
        
        if showChannel && video?.channelID != nil {
            actions.append(UIAction(__title: "View channel", image: UIImage(systemName: "person.crop.circle"), options: []) { action in
                let channel = InvidiousChannel(identifier: self.video!.channelID!)
                channel.title = self.video?.channelTitle
                channel.subscribers = self.video?.channelSubCount
                channel.thumbnails = self.video?.channelThumbnails
                let viewController = ChannelViewController(channel: channel)
                openViewController(viewController)
            })
        }
        
        actions.append(UIAction(__title: "Report", image: UIImage(systemName: "flag"), options: [.destructive]) { action in
            print("should report video with title \"\(self.video!.title!)\"")
        })
        
        return UIMenu(title: "", image: nil, identifier: nil, children: actions)
    }
    
    @available(iOS 13, *)
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, willCommitWithAnimator animator: UIContextMenuInteractionCommitAnimating) {
        animator.addCompletion {
            
        }
    }
    
}

class VideoView: UIView, UIContextMenuInteractionDelegate { // remove the context menu stuff until ios 13 comes out
    
    let mainView = UIView()
    let thumbnail = UIImageView()
    let title = UILabel()
    let channelTitle = UILabel()
    
    let publishedLabel = UILabel()
    let infoLabel = UILabel()
    
    let length = UILabel()
    let lengthBackground = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    
    let channelAvatar = UIImageView()
    
    let button = UIButton()
    let channelButton = UIButton()
    let menuButton = UIButton(type: .detailDisclosure)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.frame.size.height = ((frame.width - 32) * 9/16 + 96)
        
        tap = {
            openVideo(self.video)
        }
        
        hold = {
            let menuViewController = PopMenuViewController(sourceView: self.menuButton, actions: [])
            if settings.signedIn {
                menuViewController.addAction(
                    PopMenuDefaultAction(title: (self.rating == .liked) ? "Remove like" : "Like", image: UIImage(named: (self.rating == .liked) ? "no rating" : "like"), color: nil, didSelect: { (action) in
                        if let id = self.video?.identifier {
                            let video = YTVideo(identifier: id)
                            video.setRating((self.rating == .liked) ? .noRating : .liked, {
                                self.getRating()
                            })
                        }
                    })
                )
                menuViewController.addAction(
                    PopMenuDefaultAction(title: (self.rating == .disliked) ? "Remove dislike" : "Dislike", image: UIImage(named: (self.rating == .disliked) ? "no rating" : "dislike"), color: nil, didSelect: { (action) in
                        if let id = self.video?.identifier {
                            let video = YTVideo(identifier: id)
                            video.setRating((self.rating == .disliked) ? .noRating : .disliked, {
                                self.getRating()
                            })
                        }
                    })
                )
            }
            
            menuViewController.addAction(
                PopMenuDefaultAction(title: "Share...", image: UIImage(named: "share_filled"), color: nil, didSelect: { (action) in
                    if let id = self.video?.identifier {
                        let url = URL(string: "https://www.youtube.com/watch?v=\(id)")!
                        let activity = UIActivityViewController(activityItems: [url], applicationActivities: nil)
                        activity.popoverPresentationController?.sourceView = self.viewController?.view
                        activity.view.tintColor = interface.tintColor
                        
                        menuViewController.dismiss(animated: true, completion: {
                            self.viewController?.present(activity, animated: true)
                        })
                    }
                })
            )
            
            if self.showChannel {
                if let id = self.video?.channelID {
                    menuViewController.addAction(
                        PopMenuDefaultAction(title: "Open channel", image: UIImage(named: "account"), color: nil, didSelect: { (action) in
                            openViewController(ChannelViewController(channel: InvidiousChannel(identifier: id)))
                        })
                    )
                }
            }
            
            menuViewController.shouldEnableHaptics = settings.useHapticFeedback
            menuViewController.appearance = interface.popMenuAppearance
            UIHapticFeedback.generate(style: .selection)
            UIView.animate(withDuration: 0.125, animations: {
                self.transform = CGAffineTransform(scaleX: 1, y: 1)
                self.alpha = 1
            })
            self.viewController?.present(menuViewController, animated: true, completion: nil)
        }
        
        button.addTarget(self, action: #selector(self.pressDown(_:)), for: .touchDown)
        button.addTarget(self, action: #selector(self.release(_:)), for: .touchUpInside)
        button.addTarget(self, action: #selector(self.wasCancelled(_:)), for: .touchDragExit)
        button.addTarget(self, action: #selector(self.pressDown(_:)), for: .touchDragEnter)
        button.addTarget(self, action: #selector(self.cancel(_:)), for: .touchUpOutside)
        button.addTarget(self, action: #selector(self.wasCancelled(_:)), for: .touchCancel)
        
        channelButton.addTargetClosure { (button) in
            if let id = self.video?.channelID {
                openViewController(ChannelViewController(channel: InvidiousChannel(identifier: id)))
            }
        }
        
        menuButton.setImage(UIImage(named: "more"), for: .normal)
        menuButton.imageView?.contentMode = .scaleAspectFill
        menuButton.tintColor = UIColor(white: 0.5, alpha: 1/3)
        menuButton.addTargetClosure { (button) in
            self.hold?()
        }
        
        addSubview(mainView)
        mainView.addSubview(thumbnail)
        mainView.addSubview(title)
        mainView.addSubview(channelAvatar)
        mainView.addSubview(channelTitle)
        mainView.addSubview(publishedLabel)
        mainView.addSubview(infoLabel)
        mainView.addSubview(button)
        mainView.addSubview(channelButton)
        if #available(iOS 13, *) {
            let interaction = UIContextMenuInteraction(delegate: self)
            mainView.addInteraction(interaction)
            hold = {} // nifty ios 13 features, don't enable them till later tho
        } else {
            mainView.addSubview(menuButton)
        }
        isIndividual = true
        
        NotificationCenter.default.addObserver(forName: .themeChanged, object: nil, queue: .main) { (notification) in
            self.updateTheme(animated: true)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    var video: InvidiousVideo? {
        didSet {
            update()
        }
    }
    
    var isIndividual = true {
        didSet {
            layoutSubviews()
        }
    }
    
    var showChannel = true {
        didSet {
            layoutSubviews()
        }
    }
    
    var shadow = true {
        didSet {
            layoutSubviews()
        }
    }
    
    var onFrameChange: (() -> Void)?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        mainView.frame = CGRect(x: 16, y: 0, width: self.frame.width - 32, height: self.frame.height)
        mainView.layer.cornerRadius = 20
        mainView.clipsToBounds = true
        
        thumbnail.frame = CGRect(x: 0, y: 0, width: mainView.frame.width, height: mainView.frame.width * 9/16)
        thumbnail.layer.cornerRadius = !isIndividual ? 20 : 0
        thumbnail.contentMode = .scaleAspectFill
        thumbnail.clipsToBounds = true
        
        title.frame = CGRect(x: 8, y: thumbnail.frame.maxY + 8, width: mainView.frame.width - 16, height: title.frame.height)
        title.font = .systemFont(ofSize: 16, weight: .bold)
        title.numberOfLines = 2
        
        if showChannel {
            channelAvatar.frame = CGRect(x: 8, y: title.frame.maxY + 8, width: 32, height: 32)
            channelAvatar.layer.cornerRadius = 16
            channelAvatar.clipsToBounds = true
            channelAvatar.isHidden = false
            
            channelTitle.frame = CGRect(x: channelAvatar.frame.maxX + 8, y: channelAvatar.frame.origin.y, width: mainView.frame.width - channelAvatar.frame.maxX - 8 - 8, height: 18)
            channelTitle.font = .systemFont(ofSize: 14, weight: .semibold)
            channelTitle.isHidden = false
            
            publishedLabel.frame = CGRect(x: channelTitle.frame.origin.x, y: channelTitle.frame.maxY, width: channelTitle.frame.width * 2/3, height: 12)
            publishedLabel.font = .systemFont(ofSize: 11, weight: .regular)
            publishedLabel.textAlignment = .left
            
            infoLabel.frame = CGRect(x: publishedLabel.frame.maxX + 2, y: publishedLabel.frame.origin.y, width: channelTitle.frame.width / 3 - 8, height: 12)
            infoLabel.font = .systemFont(ofSize: 11, weight: .regular)
            infoLabel.textAlignment = .right
            channelButton.frame = CGRect(x: 0, y: frame.height - channelAvatar.frame.height - 16, width: mainView.frame.width/2, height: 64)
            channelButton.isUserInteractionEnabled = true
            
            title.frame.size.width = mainView.frame.width - 16 - 20
            
            menuButton.frame = CGRect(x: thumbnail.frame.width - 16 - 8, y: thumbnail.frame.height + 10, width: 16, height: 16)
            menuButton.transform = CGAffineTransform(rotationAngle: π/2)
        } else {
            channelAvatar.isHidden = true
            channelTitle.isHidden = true
            
            publishedLabel.frame = CGRect(x: 8, y: mainView.frame.height - 32 - 8, width: mainView.frame.width - 16, height: 14)
            publishedLabel.font = .systemFont(ofSize: 13, weight: .regular)
            publishedLabel.textAlignment = .natural
            
            infoLabel.frame = CGRect(x: 8, y: publishedLabel.frame.maxY + 4, width: publishedLabel.frame.width, height: 14)
            infoLabel.font = .systemFont(ofSize: 13, weight: .regular)
            infoLabel.textAlignment = .natural
            channelButton.isUserInteractionEnabled = false
            
            menuButton.frame = CGRect(x: mainView.frame.width - 8 - 16, y: mainView.frame.height - 16, width: 16, height: 16)
            menuButton.transform = CGAffineTransform(rotationAngle: 0)
        }
        
        layer.shadowPath = UIBezierPath(roundedRect: (isIndividual ? mainView.frame : CGRect(origin: mainView.frame.origin, size: thumbnail.frame.size)), cornerRadius: 20).cgPath
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 10)
        layer.shadowRadius = 10
        layer.shadowOpacity = isIndividual ? 0 : (shadow ? 0.2 : 0)
        mainView.layer.borderWidth = isIndividual ? 0 : 0
        
        button.frame = mainView.bounds
        updateTheme(animated: false)
        onFrameChange?()
    }
    
    var rating: YTVideo.VideoRatings?
    func getRating() {
        if settings.signedIn {
            if let id = video?.identifier {
                YTVideo(identifier: id).getRating({ (rating) in
                    self.rating = rating
                })
            }
        }
    }
    
    func update() {
        if let video = video {
            if settings.signedIn {
                getRating()
            }
            
            if let titleString = video.title {
                title.text = titleString
                title.sizeToFit()
                
                let titleHeight: CGFloat = (title.frame.height <= 20) ? 20 : 40
                title.frame.size.height = titleHeight
                frame.size.height = frame.width * 9/16 + 36 + title.frame.height
                setElementBackgrounds()
            } else {
                let video = InvidiousVideo(identifier: video.identifier)
                video.fields = [.title]
                video.getData {
                    if let titleString = video.title {
                        self.title.text = titleString
                        
                        self.title.sizeToFit()
                        let titleHeight: CGFloat = (self.title.frame.height <= 20) ? 20 : 40
                        self.title.frame.size.height = titleHeight
                        
                        self.frame.size.height = self.frame.width * 9/16 + 36 + self.title.frame.height
                        self.setElementBackgrounds()
                    }
                }
            }
            
            if let titleString = video.channelTitle {
                channelTitle.text = titleString
                setElementBackgrounds()
            } else {
                let video = InvidiousVideo(identifier: video.identifier)
                video.fields = [.channelTitle]
                video.getData {
                    if let titleString = video.channelTitle {
                        self.channelTitle.text = titleString
                        self.setElementBackgrounds()
                    }
                }
            }
            
            if let url = URL(string: video.channelThumbnails?.medium ?? "") {
                URLDataHandler.downloadImage(url: url) { (image) in
                    self.channelAvatar.image = image
                    self.setElementBackgrounds()
                }
            } else {
                let video = InvidiousVideo(identifier: video.identifier)
                video.fields = [.channelThumbnails]
                video.getData {
                    if let url = URL(string: video.channelThumbnails?.medium ?? "") {
                        URLDataHandler.downloadImage(url: url) { (image) in
                            self.channelAvatar.image = image
                            self.setElementBackgrounds()
                        }
                    }
                }
            }
            
            if let url = URL(string: video.thumbnails?.high ?? "") {
                URLDataHandler.downloadImage(url: url) { (image) in
                    self.thumbnail.image = image
                    self.setElementBackgrounds()
                }
            } else {
                let video = InvidiousVideo(identifier: video.identifier)
                video.fields = [.thumbnails]
                video.getData {
                    if let url = URL(string: video.thumbnails?.high ?? "") {
                        URLDataHandler.downloadImage(url: url) { (image) in
                            self.thumbnail.image = image
                            self.setElementBackgrounds()
                        }
                    }
                }
            }
            
            if let lengthInt = video.length {
                let formatter = DateComponentsFormatter()
                formatter.allowedUnits = [.second, .minute, .hour, .day]
                formatter.zeroFormattingBehavior = .dropLeading
                length.text = formatter.string(from: Double(lengthInt))
                setElementBackgrounds()
            } else {
                let video = InvidiousVideo(identifier: video.identifier)
                video.fields = [.length]
                video.getData {
                    if let lengthInt = video.length {
                        let formatter = DateComponentsFormatter()
                        formatter.allowedUnits = [.second, .minute, .hour, .day]
                        formatter.unitsStyle = .positional
                        formatter.zeroFormattingBehavior = .dropLeading
                        self.length.text = formatter.string(from: Double(lengthInt))
                        self.setElementBackgrounds()
                    }
                }
            }
            
            if let published = video.published, let views = video.views {
                let viewsString = NSNumber(integerLiteral: views).formatUsingAbbrevation()
                
                let timeFormatter = DateComponentsFormatter()
                timeFormatter.allowedUnits = [.second, .minute, .hour, .day, .month, .year]
                timeFormatter.unitsStyle = .abbreviated
                timeFormatter.maximumUnitCount = 1
                let publishedString = timeFormatter.string(from: published, to: Date())!
                
                publishedLabel.text = "\(viewsString) VIEW\(views != 1 ? "S" : "")  •  \(publishedString) AGO".uppercased()
                setElementBackgrounds()
            } else {
                let video = InvidiousVideo(identifier: video.identifier)
                video.getData(fields: [.published, .views]) {
                    if let published = video.published, let views = video.views {
                        let viewsString = NSNumber(integerLiteral: views).formatUsingAbbrevation()
                        
                        let timeFormatter = DateComponentsFormatter()
                        timeFormatter.allowedUnits = [.second, .minute, .hour, .day, .month, .year]
                        timeFormatter.unitsStyle = .abbreviated
                        timeFormatter.maximumUnitCount = 1
                        let publishedString = timeFormatter.string(from: published, to: Date())!
                        
                        self.publishedLabel.text = "\(viewsString) VIEW\(views != 1 ? "S" : "")  •  \(publishedString) AGO".uppercased()
                        self.setElementBackgrounds()
                    }
                }
            }
            
            if let likes = video.likes {
                let likesString = NSNumber(integerLiteral: likes).formatUsingAbbrevation()
                infoLabel.text = "\(likesString) LIKE\(likes != 1 ? "S" : "")"
                setElementBackgrounds()
            } else {
                let video = InvidiousVideo(identifier: video.identifier)
                video.getData(fields: [.likes]) {
                    if let likes = video.likes {
                        let likesString = NSNumber(integerLiteral: likes).formatUsingAbbrevation()
                        self.infoLabel.text = "\(likesString) LIKE\(likes != 1 ? "S" : "")"
                        self.setElementBackgrounds()
                    }
                }
            }
        }
    }
    
    func setElementBackgrounds() {
        for label in [title, channelTitle, publishedLabel, infoLabel] {
            label.clipsToBounds = true
            if label.text != nil && label.text != "" {
                label.backgroundColor = .clear
                label.layer.cornerRadius = 0
            } else {
                label.backgroundColor = interface.placeholderColor
                label.layer.cornerRadius = 6
            }
        }
        
        for view in [thumbnail, channelAvatar] {
            if view.image != nil {
                view.backgroundColor = .black
            } else {
                view.backgroundColor = interface.placeholderColor
            }
        }
    }
    
    func updateTheme(animated: Bool) {
        UIView.animate(withDuration: animated ? 0.25 : 0) {
            self.setThemes()
            self.setElementBackgrounds()
        }
    }
    
    func setThemes() {
        mainView.backgroundColor = isIndividual ? interface.contentColor : .clear
        mainView.layer.borderColor = isIndividual ? interface.textColor.withAlphaComponent(1/6).cgColor : UIColor.clear.cgColor
        menuButton.tintColor = interface.textColor.withAlphaComponent(isIndividual ? 1 : 1/3)
        for label in [title, channelTitle] {
            label.textColor = interface.textColor
        }
        for label in [publishedLabel, infoLabel] {
            label.textColor = interface.textColor.withAlphaComponent(1/2)
        }
    }
    
    var tapTimer: Timer?
    var holdTimer: Timer?
    @objc func pressDown(_ button: UIButton) {
        if #available(iOS 13, *) {
            UIView.animate(withDuration: 1/4) {
                self.alpha = 0.75
            }
        } else {
            holdTimer = Timer.scheduledTimer(withTimeInterval: 1/4, repeats: false, block: { (timer) in
                self.hold?()
                self.holdTimer = nil
            })
            UIView.animate(withDuration: 1/4) {
                self.transform = CGAffineTransform(scaleX: 0.975, y: 0.975)
                self.alpha = 0.75
            }
        }
    }
    
    @objc func release(_ button: UIButton) {
        if #available(iOS 13, *) {
            openVideo(video)
            UIView.animate(withDuration: 1/4) {
                self.alpha = 1
            }
        } else {
            if holdTimer?.isValid ?? false {
                tap?()
                holdTimer?.invalidate()
                holdTimer = nil
                layer.removeAllAnimations()
                UIView.animate(withDuration: 0.125) {
                    self.transform = CGAffineTransform(scaleX: 1, y: 1)
                    self.alpha = 1
                }
            } else if holdTimer != nil {
                hold?()
                holdTimer = nil
            }
        }
    }
    
    @objc func cancel(_ button: UIButton) {
        button.cancelTracking(with: nil)
    }
    
    @objc func wasCancelled(_ button: UIButton) {
        holdTimer?.invalidate()
        holdTimer = nil
        UIView.animate(withDuration: 0.125) {
            self.transform = CGAffineTransform(scaleX: 1, y: 1)
            self.alpha = 1
        }
    }
    
    var tap: (() -> Void)? = {}
    var hold: (() -> Void)? = {}
    
    var channelTap: (() -> Void)? = {}
    
    @available(iOS 13.0, *) // context menus don't get added till ios 13
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil, actionProvider: { suggestedActions in
            return self.contextMenu()
        })
    }
    
    @available(iOS 13.0, *)
    func contextMenu() -> UIMenu {
        var actions: [UIAction] = []
        if settings.signedIn && video?.identifier != nil {
            if self.rating != .liked {
                actions.append(UIAction(__title: "Like", image: UIImage(systemName: "hand.thumbsup"), options: []) { action in
                    self.rating = .liked
                    YTVideo(identifier: self.video!.identifier!).setRating(.liked) {
                        self.getRating()
                    }
                })
            } else {
                actions.append(UIAction(__title: "Remove like", image: UIImage(systemName: "xmark"), options: []) { action in
                    self.rating = .noRating
                    YTVideo(identifier: self.video!.identifier!).setRating(.noRating) {
                        self.getRating()
                    }
                })
            }
            
            if self.rating != .disliked {
                actions.append(UIAction(__title: "Dislike", image: UIImage(systemName: "hand.thumbsdown"), options: []) { action in
                    self.rating = .disliked
                    YTVideo(identifier: self.video!.identifier!).setRating(.disliked) {
                        self.getRating()
                    }
                })
            } else {
                actions.append(UIAction(__title: "Remove dislike", image: UIImage(systemName: "xmark"), options: []) { action in
                    self.rating = .noRating
                    YTVideo(identifier: self.video!.identifier!).setRating(.noRating) {
                        self.getRating()
                    }
                })
            }
        }
        
        if let id = video?.identifier {
            actions.append(UIAction(__title: "Share", image: UIImage(systemName: "square.and.arrow.up"), options: []) { action in
                let url = URL(string: "https://www.youtube.com/watch?v=\(id)")!
                let shareSheetViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
                shareSheetViewController.popoverPresentationController?.sourceView = self
                shareSheetViewController.view.tintColor = interface.tintColor
                self.viewController?.present(shareSheetViewController, animated: true)
            })
        }
        
        if showChannel && video?.channelID != nil {
            actions.append(UIAction(__title: "View channel", image: UIImage(systemName: "person.crop.circle"), options: []) { action in
                let channel = InvidiousChannel(identifier: self.video!.channelID!)
                channel.title = self.video?.channelTitle
                channel.subscribers = self.video?.channelSubCount
                channel.thumbnails = self.video?.channelThumbnails
                let viewController = ChannelViewController(channel: channel)
                openViewController(viewController)
            })
        }
        
        actions.append(UIAction(__title: "Report", image: UIImage(systemName: "flag"), options: [.destructive]) { action in
            print("should report video with title \"\(self.video!.title!)\"")
        })
        
        return UIMenu(__title: "", image: nil, identifier: nil, children: actions)
    }
    
    @available(iOS 13, *)
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, willCommitWithAnimator animator: UIContextMenuInteractionCommitAnimating) {
        animator.addCompletion {
            self.tap?()
        }
    }
    
}

class SmallVideoView: UIView {
    
    let mainView = UIView()
    let thumbnail = UIImageView()
    let title = UILabel()
    let channelTitle = UILabel()
    let infoLabel = UILabel()
    
    let button = UIButton()
    let channelButton = UIButton()
    let menuButton = UIButton(type: .detailDisclosure)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.frame.size.height = 75
        
        tap = {
            openVideo(self.video)
        }
        
        hold = {
            let menuViewController = PopMenuViewController(sourceView: self.menuButton, actions: [])
            if settings.signedIn {
                menuViewController.addAction(
                    PopMenuDefaultAction(title: (self.rating == .liked) ? "Remove like" : "Like", image: UIImage(named: (self.rating == .liked) ? "no rating" : "like"), color: nil, didSelect: { (action) in
                        if let id = self.video?.identifier {
                            let video = YTVideo(identifier: id)
                            video.setRating((self.rating == .liked) ? .noRating : .liked, {
                                self.getRating()
                            })
                        }
                    })
                )
                menuViewController.addAction(
                    PopMenuDefaultAction(title: (self.rating == .disliked) ? "Remove dislike" : "Dislike", image: UIImage(named: (self.rating == .disliked) ? "no rating" : "dislike"), color: nil, didSelect: { (action) in
                        if let id = self.video?.identifier {
                            let video = YTVideo(identifier: id)
                            video.setRating((self.rating == .disliked) ? .noRating : .disliked, {
                                self.getRating()
                            })
                        }
                    })
                )
            }
            
            menuViewController.addAction(
                PopMenuDefaultAction(title: "Share...", image: UIImage(named: "share_filled"), color: nil, didSelect: { (action) in
                    if let id = self.video?.identifier {
                        let url = URL(string: "https://www.youtube.com/watch?v=\(id)")!
                        let activity = UIActivityViewController(activityItems: [url], applicationActivities: nil)
                        activity.popoverPresentationController?.sourceView = self.viewController?.view
                        activity.view.tintColor = interface.tintColor
                        
                        menuViewController.dismiss(animated: true, completion: {
                            self.viewController?.present(activity, animated: true)
                        })
                    }
                })
            )
            
            if self.showChannel {
                if let id = self.video?.channelID {
                    menuViewController.addAction(
                        PopMenuDefaultAction(title: "Open channel", image: UIImage(named: "account"), color: nil, didSelect: { (action) in
                            openViewController(ChannelViewController(channel: InvidiousChannel(identifier: id)))
                        })
                    )
                }
            }
            
            menuViewController.shouldEnableHaptics = settings.useHapticFeedback
            menuViewController.appearance = interface.popMenuAppearance
            UIHapticFeedback.generate(style: .selection)
            UIView.animate(withDuration: 0.125, animations: {
                self.transform = CGAffineTransform(scaleX: 1, y: 1)
                self.alpha = 1
            })
            self.viewController?.present(menuViewController, animated: true, completion: nil)
        }
        
        button.addTarget(self, action: #selector(self.pressDown(_:)), for: .touchDown)
        button.addTarget(self, action: #selector(self.release(_:)), for: .touchUpInside)
        button.addTarget(self, action: #selector(self.wasCancelled(_:)), for: .touchDragExit)
        button.addTarget(self, action: #selector(self.pressDown(_:)), for: .touchDragEnter)
        button.addTarget(self, action: #selector(self.cancel(_:)), for: .touchUpOutside)
        button.addTarget(self, action: #selector(self.wasCancelled(_:)), for: .touchCancel)
        
        channelButton.addTargetClosure { (button) in
            if let id = self.video?.channelID {
                let channel = InvidiousChannel(identifier: id)
                channel.title = self.video?.channelTitle
                channel.subscribers = self.video?.channelSubCount
                channel.thumbnails = self.video?.channelThumbnails
                openViewController(ChannelViewController(channel: channel))
            }
        }
        
        menuButton.setImage(UIImage(named: "more"), for: .normal)
        menuButton.imageView?.contentMode = .scaleAspectFill
        menuButton.addTargetClosure { (button) in
            self.hold?()
        }
        
        addSubview(mainView)
        mainView.addSubview(thumbnail)
        mainView.addSubview(title)
        mainView.addSubview(channelTitle)
        mainView.addSubview(infoLabel)
        mainView.addSubview(button)
        mainView.addSubview(channelButton)
        mainView.addSubview(menuButton)
        
        isIndividual = true
        
        NotificationCenter.default.addObserver(forName: .themeChanged, object: nil, queue: .main) { (notification) in
            self.updateTheme(animated: true)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    var video: InvidiousVideo? {
        didSet {
            update()
        }
    }
    
    var isIndividual = true {
        didSet {
            layoutSubviews()
        }
    }
    
    var showChannel = true {
        didSet {
            layoutSubviews()
        }
    }
    
    var onFrameChange: (() -> Void)?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        mainView.frame = CGRect(x: 16, y: 0, width: frame.width - 32, height: frame.height)
        mainView.layer.cornerRadius = 20
        mainView.clipsToBounds = true
        
        thumbnail.frame = CGRect(x: 0, y: 0, width: mainView.frame.height * 16/9, height: mainView.frame.height)
        thumbnail.layer.cornerRadius = !isIndividual ? 20 : 0
        thumbnail.contentMode = .scaleAspectFill
        thumbnail.clipsToBounds = true
        
        title.frame = CGRect(x: thumbnail.frame.width + 8, y: 4, width: mainView.frame.width - thumbnail.frame.width - 8 - 8, height: 40)
        title.font = .systemFont(ofSize: 16, weight: .bold)
        title.numberOfLines = 2
        
        if showChannel {
            channelTitle.frame = CGRect(x: title.frame.origin.x, y: title.frame.maxY, width: title.frame.width, height: 14)
            channelTitle.font = .systemFont(ofSize: 12, weight: .semibold)
            channelTitle.isHidden = false
            
            channelButton.frame = channelTitle.frame
            channelButton.isUserInteractionEnabled = true
        } else {
            channelTitle.frame = CGRect(x: title.frame.origin.x, y: title.frame.maxY, width: title.frame.width, height: 0)
            channelTitle.isHidden = true
            
            channelButton.isUserInteractionEnabled = false
        }
        
        mainView.layer.borderWidth = isIndividual ? 0 : 0
        
        menuButton.frame = CGRect(x: mainView.frame.width - 16 - 8, y: mainView.frame.height - 8 - 8, width: 16, height: 16)
        
        infoLabel.frame = CGRect(x: channelTitle.frame.minX, y: channelTitle.frame.maxY, width: channelTitle.frame.width - (showChannel ? menuButton.frame.width : 0), height: 12)
        infoLabel.font = .systemFont(ofSize: 11, weight: .regular)
        
        button.frame = mainView.bounds
        updateTheme(animated: false)
        setElementBackgrounds()
        onFrameChange?()
    }
    
    var rating: YTVideo.VideoRatings?
    func getRating() {
        if settings.signedIn {
            if let id = video?.identifier {
                let video = YTVideo(identifier: id)
                video.getRating({ (rating) in
                    self.rating = rating
                })
            }
        }
    }
    
    func update() {
        if let video = video {
            if settings.signedIn {
                getRating()
            }
            
            if let titleString = video.title {
                title.text = titleString
                setElementBackgrounds()
            } else {
                let video = InvidiousVideo(identifier: video.identifier)
                video.fields = [.title]
                video.getData {
                    if let titleString = video.title {
                        self.title.text = titleString
                        self.setElementBackgrounds()
                    }
                }
            }
            
            if let titleString = video.channelTitle {
                channelTitle.text = titleString
                setElementBackgrounds()
            } else {
                let video = InvidiousVideo(identifier: video.identifier)
                video.fields = [.channelTitle]
                video.getData {
                    if let titleString = video.channelTitle {
                        self.channelTitle.text = titleString
                        self.setElementBackgrounds()
                    }
                }
            }
            
            if let thumbnailURL = video.thumbnails?.low {
                URLDataHandler.downloadImage(url: URL(string: thumbnailURL)!) { (image) in
                    self.thumbnail.image = image
                    self.setElementBackgrounds()
                }
            } else {
                let video = InvidiousVideo(identifier: video.identifier)
                video.getData(fields: [.thumbnails]) {
                    if let thumbnailURL = video.thumbnails?.low {
                        URLDataHandler.downloadImage(url: URL(string: thumbnailURL)!) { (image) in
                            self.thumbnail.image = image
                            self.setElementBackgrounds()
                        }
                    }
                }
            }
            
            /*if let lengthInt = video.length {
                let formatter = DateComponentsFormatter()
                formatter.allowedUnits = [.second, .minute, .hour, .day]
                formatter.zeroFormattingBehavior = .dropLeading
                length.text = formatter.string(from: Double(lengthInt))
                setElementBackgrounds()
            } else {
                let video = InvidiousVideo(identifier: video.identifier)
                video.fields = [.length]
                video.getData {
                    if let lengthInt = video.length {
                        let formatter = DateComponentsFormatter()
                        formatter.allowedUnits = [.second, .minute, .hour, .day]
                        formatter.unitsStyle = .positional
                        formatter.zeroFormattingBehavior = .dropLeading
                        self.length.text = formatter.string(from: Double(lengthInt))
                        self.setElementBackgrounds()
                    }
                }
            }*/
            
            if let published = video.published, let views = video.views {
                let viewsString = NSNumber(integerLiteral: views).formatUsingAbbrevation()
                
                let timeFormatter = DateComponentsFormatter()
                timeFormatter.allowedUnits = [.second, .minute, .hour, .day, .month, .year]
                timeFormatter.unitsStyle = .abbreviated
                timeFormatter.maximumUnitCount = 1
                let publishedString = timeFormatter.string(from: published, to: Date())!
                
                infoLabel.text = "\(viewsString) VIEW\(views != 1 ? "S" : "")  •  \(publishedString) AGO".uppercased()
                setElementBackgrounds()
            } else {
                let video = InvidiousVideo(identifier: video.identifier)
                video.getData(fields: [.published, .views]) {
                    if let published = video.published, let views = video.views {
                        let viewsString = NSNumber(integerLiteral: views).formatUsingAbbrevation()
                        
                        let timeFormatter = DateComponentsFormatter()
                        timeFormatter.allowedUnits = [.second, .minute, .hour, .day, .month, .year]
                        timeFormatter.unitsStyle = .abbreviated
                        timeFormatter.maximumUnitCount = 1
                        let publishedString = timeFormatter.string(from: published, to: Date())!
                        
                        self.infoLabel.text = "\(viewsString) VIEW\(views != 1 ? "S" : "")  •  \(publishedString) AGO".uppercased()
                        self.setElementBackgrounds()
                    }
                }
            }
        }
    }
    
    func setElementBackgrounds() {
        for label in [title, channelTitle, infoLabel] {
            label.clipsToBounds = true
            if label.text != nil && label.text != "" {
                label.backgroundColor = .clear
                label.layer.cornerRadius = 0
            } else {
                label.backgroundColor = interface.placeholderColor
                label.layer.cornerRadius = 6
            }
        }
        
        if thumbnail.image != nil {
            thumbnail.backgroundColor = .black
        } else {
            thumbnail.backgroundColor = interface.placeholderColor
        }
    }
    
    func updateTheme(animated: Bool) {
        UIView.animate(withDuration: animated ? 0.25 : 0) {
            self.setThemes()
        }
    }
    
    func setThemes() {
        mainView.backgroundColor = isIndividual ? interface.contentColor : .clear
        mainView.layer.borderColor = isIndividual ? interface.textColor.withAlphaComponent(1/6).cgColor : UIColor.clear.cgColor
        title.textColor = interface.textColor
        channelTitle.textColor = interface.textColor
        infoLabel.textColor = interface.textColor.withAlphaComponent(1/2)
        menuButton.tintColor = interface.textColor.withAlphaComponent(isIndividual ? 1 : 1/3)
    }
    
    var tapTimer: Timer?
    var holdTimer: Timer?
    @objc func pressDown(_ button: UIButton) {
        holdTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { (timer) in
            self.hold?()
            self.holdTimer = nil
        })
        UIView.animate(withDuration: 0.125) {
            self.transform = CGAffineTransform(scaleX: 0.975, y: 0.975)
            self.alpha = 0.75
        }
    }
    
    @objc func release(_ button: UIButton) {
        if holdTimer?.isValid ?? false {
            tap?()
            holdTimer?.invalidate()
            holdTimer = nil
            UIView.animate(withDuration: 0.125) {
                self.transform = CGAffineTransform(scaleX: 1, y: 1)
                self.alpha = 1
            }
        } else if holdTimer != nil {
            hold?()
            holdTimer = nil
        }
    }
    
    @objc func cancel(_ button: UIButton) {
        button.cancelTracking(with: nil)
    }
    
    @objc func wasCancelled(_ button: UIButton) {
        holdTimer?.invalidate()
        holdTimer = nil
        UIView.animate(withDuration: 0.125) {
            self.transform = CGAffineTransform(scaleX: 1, y: 1)
            self.alpha = 1
        }
    }
    
    var tap: (() -> Void)? = {}
    var hold: (() -> Void)? = {}
    
    var channelTap: (() -> Void)? = {}
    
}

class ChannelView: UIView {
    
    let mainView = UIView()
    let title = UILabel()
    let infoLabel = UILabel()
    let avatar = UIImageView()
    
    let button = UIButton()
    let subscribeButton = UIButton(type: .roundedRect)
    
    var channel: InvidiousChannel? {
        didSet {
            update()
        }
    }
    
    var isIndividual = true {
        didSet {
            setThemes()
        }
    }
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    convenience init(frame: CGRect, channel: InvidiousChannel?) {
        self.init(frame: frame)
        self.channel = channel
        update()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.frame.size.height = 60
        
        hold = {
            let menuViewController = PopMenuViewController(sourceView: self, actions: [
                PopMenuDefaultAction(title: "Share...", image: UIImage(named: "share_filled"), color: nil, didSelect: { (action) in
                    if let id = self.channel?.identifier {
                        UIHapticFeedback.generate(style: .impactLight)
                        let url = URL(string: "https://www.youtube.com/channel/\(id)")!
                        let activity = UIActivityViewController(activityItems: [url], applicationActivities: nil)
                        activity.popoverPresentationController?.sourceView = self.viewController?.view
                        activity.view.tintColor = interface.tintColor
                        
                        action.view.viewController?.dismiss(animated: true, completion: {
                            self.viewController?.present(activity, animated: true)
                        })
                    } else {
                        let error = UIAlertController(title: "Couldn't share that channel", message: nil, preferredStyle: .alert)
                        error.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
                        error.view.tintColor = interface.tintColor
                        action.view.viewController?.dismiss(animated: true, completion: {
                            UIHapticFeedback.generate(style: .errorNotification)
                            self.viewController?.present(error, animated: true)
                        })
                    }
                })
                ], appearance: interface.popMenuAppearance)
            
            menuViewController.shouldEnableHaptics = false
            UIHapticFeedback.generate(style: .selection)
            UIView.animate(withDuration: 0.125, animations: {
                self.transform = CGAffineTransform(scaleX: 1, y: 1)
                self.alpha = 1
            })
            self.viewController?.present(menuViewController, animated: true)
        }
        
        tap = {
            if let id = self.channel?.identifier {
                UIHapticFeedback.generate(style: .impactLight)
                openViewController(ChannelViewController(channel: InvidiousChannel(identifier: id)))
            }
        }
        
        button.addTarget(self, action: #selector(self.pressDown(_:)), for: .touchDown)
        button.addTarget(self, action: #selector(self.release(_:)), for: .touchUpInside)
        button.addTarget(self, action: #selector(self.wasCancelled(_:)), for: .touchDragExit)
        button.addTarget(self, action: #selector(self.pressDown(_:)), for: .touchDragEnter)
        button.addTarget(self, action: #selector(self.cancel(_:)), for: .touchUpOutside)
        button.addTarget(self, action: #selector(self.wasCancelled(_:)), for: .touchCancel)
        
        subscribeButton.setImage(UIImage(named: "plus"), for: .normal)
        subscribeButton.tintColor = interface.tintColor
        subscribeButton.imageView?.contentMode = .scaleAspectFit
        subscribeButton.isEnabled = false
        subscribeButton.addTargetClosure { (button) in
            UIHapticFeedback.generate(style: .successNotification)
            UIView.animate(withDuration: 0.25, animations: {
                button.transform = CGAffineTransform(rotationAngle: π/4)
            })
        }
        
        mainView.layer.cornerRadius = 20
        mainView.clipsToBounds = true
        
        avatar.clipsToBounds = true
        
        title.font = .systemFont(ofSize: 18, weight: .bold)
        infoLabel.font = .systemFont(ofSize: 11, weight: .regular)
        
        addSubview(mainView)
        mainView.addSubview(title)
        mainView.addSubview(infoLabel)
        mainView.addSubview(subscribeButton)
        mainView.addSubview(avatar)
        mainView.addSubview(button)
        
        updateTheme(animated: false)
        
        NotificationCenter.default.addObserver(forName: .themeChanged, object: nil, queue: .main) { (notification) in
            self.updateTheme(animated: true)
        }
        
        NotificationCenter.default.addObserver(forName: .signedIn, object: nil, queue: .main) { (notification) in
            self.subscribeButton.isEnabled = settings.signedIn
        }
        
        NotificationCenter.default.addObserver(forName: .signedOut, object: nil, queue: .main) { (notification) in
            self.subscribeButton.isEnabled = settings.signedIn
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        frame.size.height = 60
        
        mainView.frame = CGRect(x: 16, y: 0, width: frame.width - 32, height: frame.height)
        
        button.frame = mainView.bounds
        
        avatar.frame = CGRect(x: 8, y: 8, width: mainView.frame.height - 16, height: mainView.frame.height - 16)
        avatar.layer.cornerRadius = avatar.frame.width / 2
        
        let subscribeButtonSize: CGFloat = 30
        subscribeButton.frame = CGRect(x: mainView.frame.width - subscribeButtonSize - 16, y: (mainView.frame.height - subscribeButtonSize) / 2, width: subscribeButtonSize, height: subscribeButtonSize)
        
        title.frame = CGRect(x: avatar.frame.maxX + 8, y: mainView.frame.height/2 - 17, width: mainView.frame.width - avatar.frame.maxX - 32 - subscribeButtonSize, height: 20)
        
        infoLabel.frame = CGRect(x: title.frame.origin.x, y: title.frame.maxY + 2, width: title.frame.width, height: 12)
    }
    
    func update() {
        if let channel = channel {
            if channel.title != nil {
                title.text = channel.title
                setElementBackgrounds()
            } else {
                let info = InvidiousChannel(identifier: channel.identifier)
                info.getData(fields: [.title]) {
                    self.title.text = channel.title
                    self.setElementBackgrounds()
                }
            }
            
            if let url = URL(string: channel.thumbnails?.low ?? "") {
                URLDataHandler.downloadImage(url: url) { (image) in
                    self.avatar.image = image
                    self.setElementBackgrounds()
                }
            } else {
                let info = InvidiousChannel(identifier: channel.identifier)
                info.getData(fields: [.thumbnails]) {
                    if let url = URL(string: info.thumbnails?.low ?? "") {
                        URLDataHandler.downloadImage(url: url) { (image) in
                            self.avatar.image = image
                            self.setElementBackgrounds()
                        }
                    }
                }
            }
            
            if channel.subscribers != nil {
                if let subs = channel.subscribers {
                    var string = NSNumber(integerLiteral: subs).formatUsingAbbrevation()
                    string.append(" SUBSCRIBER")
                    string.append((subs != 1) ? "S" : "")
                    infoLabel.text = string
                    setElementBackgrounds()
                }
            } else {
                let info = InvidiousChannel(identifier: channel.identifier)
                info.getData(fields: [.subscribers]) {
                    if let subs = info.subscribers {
                        var string = NSNumber(integerLiteral: subs).formatUsingAbbrevation()
                        string.append(" SUBSCRIBER")
                        string.append((subs != 1) ? "S" : "")
                        self.infoLabel.text = string
                        self.setElementBackgrounds()
                    }
                }
            }
        }
        
        setElementBackgrounds()
    }
    
    func setElementBackgrounds() {
        for label in [title, infoLabel] {
            label.clipsToBounds = true
            if label.text != nil && label.text != "" {
                label.backgroundColor = .clear
                label.layer.cornerRadius = 0
            } else {
                label.backgroundColor = interface.placeholderColor
                label.layer.cornerRadius = 6
            }
        }
        
        if avatar.image != nil {
            avatar.backgroundColor = .clear
        } else {
            avatar.backgroundColor = interface.placeholderColor
        }
    }
    
    func updateTheme(animated: Bool) {
        UIView.animate(withDuration: animated ? 0.25 : 0) {
            self.setThemes()
        }
    }
    
    func setThemes() {
        mainView.backgroundColor = isIndividual ? interface.contentColor : .clear
        title.textColor = interface.textColor
        infoLabel.textColor = interface.textColor.withAlphaComponent(1/3)
    }
    
    var tapTimer: Timer?
    var holdTimer: Timer?
    @objc func pressDown(_ button: UIButton) {
        holdTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { (timer) in
            self.hold?()
            self.holdTimer = nil
        })
        UIView.animate(withDuration: 0.125) {
            self.transform = CGAffineTransform(scaleX: 0.975, y: 0.975)
            self.alpha = 0.75
        }
    }
    
    @objc func release(_ button: UIButton) {
        if holdTimer?.isValid ?? false {
            tap?()
            holdTimer?.invalidate()
            holdTimer = nil
            UIView.animate(withDuration: 0.125) {
                self.transform = CGAffineTransform(scaleX: 1, y: 1)
                self.alpha = 1
            }
        } else if holdTimer != nil {
            hold?()
            holdTimer = nil
        }
    }
    
    @objc func cancel(_ button: UIButton) {
        button.cancelTracking(with: nil)
    }
    
    @objc func wasCancelled(_ button: UIButton) {
        holdTimer?.invalidate()
        holdTimer = nil
        UIView.animate(withDuration: 0.125) {
            self.transform = CGAffineTransform(scaleX: 1, y: 1)
            self.alpha = 1
        }
    }
    
    var tap: (() -> Void)?
    var hold: (() -> Void)?
    
}
