//
//  SubscriptionsController.swift
//  hermes
//
//  Created by Aidan Cline on 2/1/19.
//  Copyright © 2019 Aidan Cline. All rights reserved.
//

import UIKit

class Subscriptions: NavigationController {
    
    override func viewDidLoad() {
        root = SubscriptionsViewController()
        super.viewDidLoad()
    }
    
}

var subscriptions = [String]()

class SubscriptionsViewController: BaseViewController {
    
    let offsetView = UIView()
    let messageView = UILabel()
    let signInButton = UIButton(type: .roundedRect)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Subscriptions"
        showBackButton = false
        
        messageView.frame = CGRect(x: 16, y: 0, width: scrollView.frame.width - 32, height: 75)
        messageView.font = .systemFont(ofSize: 16, weight: .semibold)
        messageView.textAlignment = .center
        messageView.numberOfLines = 2

        signInButton.frame = CGRect(x: 16, y: 0, width: scrollView.frame.width - 32, height: 50)
        signInButton.layer.cornerRadius = 20
        signInButton.clipsToBounds = true
        signInButton.backgroundColor = interface.tintColor
        signInButton.setTitleColor(.white, for: .normal)
        signInButton.setTitle("Sign in", for: .normal)
        signInButton.contentHorizontalAlignment = .center
        signInButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        signInButton.addTargetClosure { (button) in
            signIn()
        }
        
        messageView.frame.origin.y = 0
        messageView.text = "You're not signed in. Sign in to see your subscriptions here."
        scrollView.addGap(height: 16)
        scrollView.addSubview(signInButton)
        scrollView.addSubview(messageView)

        NotificationCenter.default.addObserver(forName: .signedIn, object: nil, queue: .main) { (notification) in
            print("signed in")
            if settings.signedIn {
                self.scrollView.removeAllSubviews()
                self.scrollView.addSubview(self.headerDivider)
                self.update()
            }
        }
        
        NotificationCenter.default.addObserver(forName: .signedOut, object: nil, queue: .main) { (notification) in
            self.scrollView.removeAllSubviews()
            self.scrollView.addSubview(self.headerDivider)
            self.messageView.frame.origin.y = 0
            self.messageView.text = "You're not signed in. Sign in to see your subscriptions here."
            self.scrollView.addGap(height: 16)
            self.scrollView.addSubview(self.signInButton)
            self.scrollView.addSubview(self.messageView)
        }
        
        NotificationCenter.default.addObserver(forName: .subscriptionsChanged, object: nil, queue: .main) { (notification) in
            if settings.signedIn {
                self.scrollView.removeAllSubviews()
                self.scrollView.addSubview(self.headerDivider)
                self.update()
            }
        }
    }
    
    override func setThemes() {
        super.setThemes()
        messageView.textColor = interface.textColor
    }
    
    func update() {
        scrollView.removeAllSubviews()
        scrollView.addSubview(headerDivider)
        if settings.signedIn {
            let videoFrame = VideoView(frame: CGRect(x: 0, y: 0, width: scrollView.frame.width - 32, height: 0)).frame
            let subscriptionsHandler = YTSubscriptions()
            subscriptionsHandler.sort = .newest
            subscriptionsHandler.maxResults = 10
            subscriptionsHandler.getUserSubscriptions {
                subscriptions = [String]()
                if subscriptionsHandler.list.count != 0 {
                    let group = CellGroup(frame: CGRect(x: 0, y: 0, width: self.scrollView.frame.width, height: 50))
                    let cell = CellButton(frame: self.scrollView.bounds)
                    cell.title = "All subscriptions"
                    cell.isButtonActive = true
                    cell.showNavigationIndicator = true
                    cell.onTap = {
                        openViewController(SubscriptionsListViewController())
                    }
                    
                    group.addCell(cell)
                    self.scrollView.addGap(height: 16)
                    self.scrollView.addSubview(group)

                    for subscription in subscriptionsHandler.list.reversed() {
                        let channel = InvidiousChannel(identifier: subscription.identifier)
                        channel.title = subscription.title
                        let view = SubscribedChannelView(frame: CGRect(x: 0, y: 0, width: self.scrollView.frame.width, height: 24 + 8 + 8 + 8 + videoFrame.height), channel: channel)
                        self.scrollView.addGap(height: 16)
                        self.scrollView.addSubview(view)
                        view.showDivider = !(subscription.identifier == subscriptionsHandler.list.last?.identifier)
                        subscriptions.append(subscription.identifier)
                    }
                } else {
                    self.messageView.text = "You don't have any subscriptions, or there was an error loading them."
                    self.scrollView.addSubview(self.messageView)
                }
            }
        } else {
            messageView.frame.origin.y = 0
            messageView.text = "You're not signed in. Sign in to see your subscriptions here."
            scrollView.addGap(height: 16)
            scrollView.addSubview(signInButton)
            scrollView.addSubview(messageView)
        }
    }
    
}

class SubscribedChannelView: HorizontalView {
    
    let button = UIButton()
    var channel: InvidiousChannel? {
        didSet {
            updateContent()
        }
    }
    
    convenience init(frame: CGRect, channel: InvidiousChannel) {
        self.init(frame: frame)
        self.channel = channel
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        gradient.frame = self.bounds
        gradient.locations = [(20 / frame.height), 1] as [NSNumber]
        layer.insertSublayer(gradient, at: 0)
        
        button.setTitle("See All", for: .normal)
        button.setTitleColor(interface.tintColor, for: .normal)
        button.titleLabel!.font = .systemFont(ofSize: 14, weight: .regular)
        button.titleLabel?.sizeToFit()
        button.frame = button.titleLabel!.bounds
        button.frame = CGRect(x: frame.width - button.frame.width - 28, y: 4, width: button.frame.width, height: 20)
        button.addTargetClosure { button in
            let viewController = ChannelViewController(channel: self.channel)
            openViewController(viewController)
            
        }
        titleView.frame.size.width = button.frame.origin.x - titleView.frame.origin.x - 8
        addSubview(button)
        
        dividerLine.frame.size = CGSize(width: frame.width, height: 1)
        dividerLine.frame.origin.y = frame.height - 1
        addSubview(dividerLine)
        updateContent()
    }
    
    override func setThemes() {
        super.setThemes()
        self.gradient.colors = [interface.backgroundColor.cgColor, interface.accentColor.cgColor]
        self.dividerLine.alpha = 0
        if interface.style == .black {
            self.gradient.colors = [interface.backgroundColor.cgColor, interface.backgroundColor.cgColor]
            self.dividerLine.alpha = self.showDivider ? 1 : 0
        }
    }
    
    func updateContent() {
        if let channelTitle = channel?.title {
            self.title = channelTitle
        } else {
            let channel = InvidiousChannel(identifier: self.channel?.identifier)
            channel.getData(fields: [.title]) {
                self.title = channel.title
            }
        }
        
        if let videos = channel?.videos {
            for video in videos {
                let view = VideoView(frame: CGRect(x: (video.identifier == videos.first?.identifier) ? -16 : 0, y: 8, width: self.frame.width - 32, height: 0))
                view.video = video
                view.isIndividual = false
                view.showChannel = false
                self.addView(view)
            }
        } else {
            let channel = InvidiousChannel(identifier: self.channel?.identifier)
            channel.getVideos() {
                if let videos = channel.videos {
                    for video in videos[0...limit(10, max: videos.count - 1)] {
                        let view = VideoView(frame: CGRect(x: (video.identifier == videos.first?.identifier) ? 0 : -16, y: 8, width: self.frame.width - 32, height: 0))
                        view.video = video
                        view.isIndividual = false
                        view.showChannel = false
                        self.addView(view)
                    }
                }
            }
        }
    }
    
}

class HorizontalView: UIView {
    
    let titleView = UILabel()
    let scrollView = UIScrollView()
    let gradient = CAGradientLayer()
    
    let dividerLine = DividerLine()
    
    var views = [UIView]()
    var contentWidth: CGFloat = 0
    
    var showDivider = false {
        didSet {
            dividerLine.alpha = showDivider ? 1 : 0
        }
    }
    
    var title: String? {
        didSet {
            titleView.text = title
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        titleView.frame = CGRect(x: 28, y: 0, width: frame.width - 32, height: 24)
        titleView.font = .systemFont(ofSize: 20, weight: .bold)
        titleView.text = title
        addSubview(titleView)
        
        scrollView.frame = CGRect(x: 0, y: 20, width: frame.width, height: frame.height - 24)
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.alwaysBounceHorizontal = true
        scrollView.clipsToBounds = false
        addSubview(scrollView)
        
        setThemes()
        
        NotificationCenter.default.addObserver(forName: .themeChanged, object: nil, queue: .main) { (notification) in
            self.willSetThemes(animated: true)
        }
    }
    
    func addView(_ view: UIView) {
        let x = contentWidth
        contentWidth += view.frame.origin.x + view.frame.width
        view.frame.origin.x += x
        scrollView.addSubview(view)
        views.append(view)
        scrollView.contentSize = CGSize(width: contentWidth, height: scrollView.frame.height)
    }
    
    func willSetThemes(animated: Bool) {
        var time = Double.zero
        if animated { time = 0.25 }
        UIView.animate(withDuration: time) {
            self.setThemes()
        }
    }
    
    func setThemes() {
        self.titleView.textColor = interface.textColor
    }
    
    func removeAllViews() {
        for view in views {
            view.removeFromSuperview()
        }
        scrollView.contentSize.width = 0
    }
    
}
